
describe("Getting Points and Redeeming Points ", () => {
  let loyalty;
  beforeEach(async () => {
    const blockchainLoyaltyContract = await ethers.getContractFactory(
      "Loyalty"
    );
    loyalty = await blockchainLoyaltyContract.deploy();
    await loyalty.deployed();
    [
      owner,
      business1,
      business2,
      business3,
      business4,
      customer1,
      customer2,
      customer3,
      customer4,
    ] = await ethers.getSigners();

    await loyalty.connect(business1).registerCompany("Good", "321312");
    await loyalty.connect(business2).registerCompany("Some", "321312");
    await loyalty.connect(customer1).registerCustomer("better");
  });
  it("Should Give out points properly ", async () => {
   


    await loyalty.connect(business1).givingPoints(200, "better");
    await loyalty.connect(business2).givingPoints(200, "better");
    const point = await loyalty.connect(customer1).gettingPointsCompanies(); 
    // const {0 : something, 1: variable2} = point;
    // console.log(something, variable2)
    console.log(point);
  });
});
