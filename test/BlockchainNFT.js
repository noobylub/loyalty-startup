describe("NFT Testings", () => {
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
    await loyalty.connect(business3).registerCompany("Bill", "1431432");

    //customer
    await loyalty.connect(customer1).registerCustomer("better");
    await loyalty.connect(customer2).registerCustomer("Something");

    await loyalty.connect(business1).givingPoints(200, "better");
    await loyalty.connect(business2).givingPoints(200, "better");
    await loyalty.connect(business3).givingPoints(300, "better");
    await loyalty.connect(business1).givingPoints(200, "Something");
    await loyalty.connect(business2).givingPoints(200, "Something");
    await loyalty.connect(business3).givingPoints(300, "Something");
  });
  describe("Token functionalities", () => {
    beforeEach(async () => {
      //gives out points for later

      await loyalty
        .connect(business1)
        .createTokens("First Token", "Some string", 50, 100, 10); //1
      await loyalty
        .connect(business1)
        .createTokens("Good Tokens", "Some string", 50, 100, 10); //2
      await loyalty
        .connect(business2)
        .createTokens("Special Token", "Some string", 150, 100, 10); //3
      await loyalty
        .connect(business3)
        .createTokens("Premium", "Some string", 70, 100, 10); //4
    });

    it("Should create somef Company tokens and list them all for business 1", async () => {
      //list my tokens

      const companyTokens = await loyalty.connect(business1).myCompanyTokens();

      const tokens = [];
      for (let i = 0; i < companyTokens.length; i++) {
        let item = {
          tokenID: companyTokens[i].tokenID.toNumber(),
          owner: companyTokens[i].companyName,
          tokenName: companyTokens[i].name,
          uri: companyTokens[i].URI,
          pointCost: companyTokens[i].pricePoints.toNumber(),
          //tokenAmount: amountTokens[i].toNumber(),
        };
        tokens.push(item);
      }
      console.log(tokens);
    });

    it("Should create some token and have them put to sale to customers", async () => {
      const customer1Point = await loyalty
        .connect(customer1)
        .gettingDetails("Good");
      console.log(customer1Point.toNumber());
      //customer 1 named better
      await loyalty.connect(customer1).transferTokenPoints(1);
      const { 0: myTokens, 1: amountTokens } = await loyalty
        .connect(customer1)
        .showMyToken();

      console.log("Customer 1");
      let tokens = [];
      for (let i = 0; i < myTokens.length; i++) {
        let item = {
          tokenID: myTokens[i].tokenID.toNumber(),
          tokenName: myTokens[i].name,
          uri: myTokens[i].URI,
          pointCost: myTokens[i].pricePoints.toNumber(),
          tokenAmount: amountTokens[i].toNumber(),
        };
        tokens.push(item);
      }
      console.log(tokens);

      await loyalty.connect(customer2).transferTokenPoints(1);
      await loyalty.connect(customer2).transferTokenPoints(4);

      const { 0: myToken, 1: amountToken } = await loyalty
        .connect(customer2)
        .showMyToken();

      console.log("Customer 2");

      tokens = [];
      for (let i = 0; i < myToken.length; i++) {
        let item = {
          tokenID: myToken[i].tokenID.toNumber(),
          tokenName: myToken[i].name,
          uri: myToken[i].URI,
          pointCost: myToken[i].pricePoints.toNumber(),
          tokenAmount: amountToken[i].toNumber(),
        };
        tokens.push(item);
      }
      console.log(tokens);
    });

    it("should list several tokens", async () => {
      //list my tokens
      const companyTokens = await loyalty
        .connect(business1)
        .displayListTokens([1, 0, 4]);

      const tokens = [];
      for (let i = 0; i < companyTokens.length; i++) {
        let item = {
          tokenID: companyTokens[i].tokenID.toNumber(),
          owner: companyTokens[i].companyName,
          tokenName: companyTokens[i].name,
          uri: companyTokens[i].URI,
          pointCost: companyTokens[i].pricePoints.toNumber(),
          //tokenAmount: amountTokens[i].toNumber(),
        };
        tokens.push(item);
      }
      console.log(tokens);
    });

    it("Should transfer token and create/enter exclusive benefits", async () => {
      await loyalty.connect(business1).createBenefit([1, 2]);
      //list all the exclusive program that the company has
      // const allBenefits = await loyalty.connect(business1).listExclusivePrograms(); 
      // console.log(allBenefits);
    });
  });
});
