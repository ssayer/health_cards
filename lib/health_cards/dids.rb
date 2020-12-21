# frozen_string_literal: true

require 'multihashes'
require 'digest'
require 'base64'

module Dids
  # https://tools.ietf.org/html/rfc7515#section-2
  # See Base64url Encoding
  def encode(data)
    Base64.urlsafe_encode64(data.to_s, padding: false)
  end

  # https://identity.foundation/sidetree/spec/#hashing-process
  def hash(data)
    digest = Digest::SHA256.digest data
    Multihashes.encode(digest, 'sha2-256')
  end

  # https://identity.foundation/sidetree/spec/#public-key-commitment-scheme
  # canonicalize jwk encoded public key
  # hash cononicalized public key
  # hash resulting hash value again
  def reveal_commitment(jwk)
    jwk_canonicalized = jwk.to_json_c14n
    first_hash = encode hash(jwk_canonicalized)
    encode hash(first_hash)
  end

  # https://identity.foundation/sidetree/spec/#create
  def generate_did(encryption_public_jwk, signing_public_jwk, update_public_jwk, recovery_public_jwk)
    recovery_commitment = reveal_commitment(recovery_public_jwk)
    update_commitment = reveal_commitment(update_public_jwk)
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
      deltaHash: encode(hash(delta_cononical)),
      recoveryCommitment: recovery_commitment
    }
    suffix_data_canonical = suffix_data.to_json_c14n
    suffix = encode hash(suffix_data_canonical)
    suffix_data_encoded = encode(suffix_data_canonical)
    puts "did:ion:#{suffix}:#{suffix_data_encoded}"
    {
      didShort: "did:ion:#{suffix}",
      didLong: "did:ion:#{suffix}:#{suffix_data_encoded}"
    }
  end
end