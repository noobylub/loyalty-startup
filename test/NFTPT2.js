// describe("NFT testing PT2", () => {
//   let loyalty;
//   beforeEach(async () => {
//     const blockchainLoyaltyContract = await ethers.getContractFactory(
//       "Loyalty"
//     );
//     loyalty = await blockchainLoyaltyContract.deploy();
//     await loyalty.deployed();
//     [
//       owner,
//       business1,
//       business2,
//       business3,
//       business4,
//       customer1,
//       customer2,
//       customer3,
//       customer4,
//     ] = await ethers.getSigners();

//     await loyalty.connect(business1).registerCompany("Good", "321312");
//     await loyalty.connect(business2).registerCompany("Some", "321312");
//     await loyalty.connect(business3).registerCompany("Bill", "1431432");

//     //customer

//     await loyalty.connect(customer1).registerCustomer("better");
//     await loyalty.connect(customer2).registerCustomer("Something");

//     await loyalty.connect(business1).givingPoints(200, "better");
//     await loyalty.connect(business2).givingPoints(200, "better");
//     await loyalty.connect(business3).givingPoints(300, "better");
//     await loyalty.connect(business1).givingPoints(200, "Something");
//     await loyalty.connect(business2).givingPoints(200, "Something");

//     //creates tokens
//     await loyalty
//       .connect(business1)
//       .createTokens("First Token", "Some string", 50, 100, 10); //1
//     await loyalty
//       .connect(business1)
//       .createTokens("Good Tokens", "Some string", 50, 100, 10); //2
//     await loyalty
//       .connect(business2)
//       .createTokens("Special Token", "Some string", 150, 100, 10); //3
//     await loyalty
//       .connect(business3)
//       .createTokens("Premium", "Some string", 70, 100, 10); //4
//   });
//   it("Should create tokens and put them to sale to customers", async () => {
//     const customer1Point = await loyalty
//       .connect(customer2)
//       .gettingDetails("Good");
//     console.log(customer1Point.toNumber());
//   });
// });
