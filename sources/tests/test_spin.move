#[test_only]
module loterry_sc::test_spin {
    use std::signer;
    use aptos_framework::aptos_account;
    use loterry_sc::test_helper;
    use loterry_sc::luckey_wheel_ticket;
    use loterry_sc::jackpot;

    const ONE_APT: u64 = 1_00_000_000;
    const MAX_SPIN: u64 = 4_00_000;
    const COLLECTION_NAME: vector<u8> = b"collection name";

    #[test(deployer = @0xcafe, operator = @0xcafe, recipient = @0x235)]
    public entry fun test_e2e(deployer: &signer, operator: &signer, recipient: &signer) {
        test_helper::setup();
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(deployer), apts);
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(recipient), apts);
        jackpot::init(operator);
        luckey_wheel_ticket::init(operator);
        luckey_wheel_ticket::add_user_spins(operator, vector[signer::address_of(recipient)], vector[10002]);
        jackpot::test_spin(recipient, 10000);
        let user_spins_amount = luckey_wheel_ticket::get_user_spins_amount(signer::address_of(recipient));
        assert!(user_spins_amount == 2, 0);
    }

    #[test(deployer = @0xcafe, operator = @0xcafe, recipient = @0x235)]
    #[expected_failure(abort_code = 1,location=jackpot)]
    public entry fun test_fail_with_not_enough_spins(deployer: &signer, operator: &signer, recipient: &signer) {
        test_helper::setup();
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(deployer), apts);
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(recipient), apts);
        jackpot::init(operator);
        luckey_wheel_ticket::init(operator);
        luckey_wheel_ticket::add_user_spins(operator, vector[signer::address_of(recipient)], vector[1]);
        jackpot::test_spin(recipient, 1);
        jackpot::test_spin(recipient, 1);

    }

    #[test(deployer = @0xcafe, recipient = @0x235)]
    #[expected_failure(abort_code = 0,location=jackpot)]
    public entry fun test_set_operator_fail_auth(deployer: &signer, recipient: &signer) {
        test_helper::setup();
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(deployer), apts);
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(recipient), apts);
        jackpot::init(deployer);
        luckey_wheel_ticket::init(deployer);
        jackpot::set_operator(recipient, signer::address_of(recipient));
    }

    #[test(deployer = @0xcafe, operator = @0xcafe, recipient = @0x235)]
    #[expected_failure(abort_code = 0,location=luckey_wheel_ticket)]
    public entry fun test_add_user_spins_fail_auth(deployer: &signer, operator: &signer, recipient: &signer) {
        test_helper::setup();
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(deployer), apts);
        let apts = test_helper::mint_apt(8000);
        aptos_account::deposit_coins(signer::address_of(recipient), apts);
        jackpot::init(operator);
        luckey_wheel_ticket::init(operator);
        luckey_wheel_ticket::add_user_spins(recipient, vector[signer::address_of(recipient)], vector[10002]);
    }
}