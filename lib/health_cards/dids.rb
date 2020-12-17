# frozen_string_literal: true

require 'multihashes'
require 'digest'
require 'json-canonicalization'
require_relative 'digital_signature'

module Dids
  def hash(data)
    digest = Digest::SHA256.digest data
    Multihashes.encode(digest, 'sha2-256')
  end

  # canonicalize jwk encoded public key
  # hash cononicalized public key
  # hash resulting hash value again
  def reveal_commitment(jwk)
    jwk_canonicalized = jwk.to_json_c14n
    1st_hash = encode hash(jwk_canonicalized)
    encode hash(1st_hash)
  end

  def generate_did(encryption_public_jwk, signing_public_jwk, update_public_jwk, recovery_public_jwk)
    recovery_commitment = reveal_commitment(recoveryPublicJwk)
    update_commitment = reveal_commitment(updatePublicJwk)
    patches = [
      {
        action: 'add-public-keys',
        public_keys: [
          {
            id: 'signing-key-1',
            purpose: ['general', 'auth'],
            type: 'EcdsaSecp256k1VerificationKey2019',
            jwk: signing_public_jwk
          },
          {
            id: 'encryption-key-1',
            purpose: ['general', 'auth'],
            type: 'JsonWebKey2020',
            jwk: encryption_public_jwk
          }
        ]
      }
    ]
    delta = {
      updateCommitment: update_commitment,
      patches: patches
    }
    delta_cononical = delta.to_json_c14n
    suffix_data = {
      deltaHash: encode hash(delta_cononical),
      recoveryCommitment: recovery_commitment
    }
    suffix_data_canonical = suffix_data.to_json_c14n
    suffix = encode hash(suffix_data_canonical)
    suffix_data_encoded = encode(suffix_data_canonical)
    {
      did_short: 'did:ion:#{suffix}',
      did_long: 'did:ion:#{suffix}:#{suffix_data_encoded}'
    }
  end
end