#[test_only]
module loterry_sc::test_helper {
    use aptos_framework::account;
    use aptos_framework::stake;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::coin::Coin;
    use aptos_framework::randomness;
    use aptos_framework::timestamp;

    const MIN_APT_STAKE: u64 = 1000;
    const INITIAL_TIME: u64 = 1691370815;
    const ONE_APT: u64 = 100000000;
    const COLLECTION_NAME: vector<u8> = b"collection name";
    const COLLECTION_DES: vector<u8> = b"collection description";
    const COLLECTION_URI: vector<u8> = b"collection uri";

    public fun setup() {
        timestamp::set_time_has_started_for_testing(&account::create_signer_for_test(@0x1));
        stake::initialize_for_test(&account::create_signer_for_test(@0x1));
        randomness::initialize(&account::create_signer_for_test(@0x1));
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000001");
    }

    public fun mint_apt(apt_amount: u64): Coin<AptosCoin> {
        stake::mint_coins(apt_amount * ONE_APT)
    }
}