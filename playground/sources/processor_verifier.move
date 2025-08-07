// module ProcessorVerifier::processor_verifier {
//     use aptos_framework::ed25519;
//     use std::vector;

//     /// Verifies the signature is valid for the message and pubkey,
//     /// and that the derived address matches the expected address
//     public fun verify_signature(
//         message: vector<u8>,
//         signature: vector<u8>,
//         pubkey: vector<u8>,
//         expected_address: address
//     ): bool {
//         // 1. Verify the signature
//         let verified = ed25519::public_key_validates_signature(&message, &signature, &pubkey);
//         if (!verified) {
//             return false;
//         };

//         // 2. Check that address derived from pubkey matches expected address
//         let derived_address = aptos_framework::account::create_address_from_ed25519_public_key(&pubkey);
//         derived_address == expected_address
//     }
// }
