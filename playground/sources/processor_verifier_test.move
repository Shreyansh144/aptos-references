// module ProcessorVerifier::processor_verifier_test {
//     use ProcessorVerifier::processor_verifier;

//     #[test]
//     public fun test_verify_signature() {
//         let message = b"test-message";
//         let pubkey = x"sdfsdklklsdf";     // 32 bytes
//         let signature = x"lsjdfklsdlsdfsd";   // 64 bytes
//         let expected_address = @ProcessorVerifier;

//         let ok = processor_verifier::verify_signature(message, signature, pubkey, expected_address);
//         assert!(ok, 101);
//     }
// }
