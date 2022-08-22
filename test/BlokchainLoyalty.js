
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
    await loyalty.connect(business3).registerCompany("Bill", "1431432");
    await loyalty.connect(customer1).registerCustomer("better");

    //gives out points for later
    await loyalty.connect(business1).givingPoints(200, "better");
    await loyalty.connect(business2).givingPoints(200, "better");
    await loyalty.connect(business3).givingPoints(300, "better"); 

    //creates program to purchase
    await loyalty.connect(business1).createProgram("Random", "fsdfsdaf", 200); 
    await loyalty.connect(business1).createProgram("loko", "dsfa", 100); 
    await loyalty.connect(business1).createProgram("child", "something0", 50);
    await loyalty.connect(business1).createProgram("temptation", "dsfa", 100);
  });
  // it("Should Give out points properly ", async () => {
  //   await loyalty.connect(business1).givingPoints(200, "better");
  //   await loyalty.connect(business2).givingPoints(200, "better");
  //   await loyalty.connect(business3).givingPoints(300, "better"); 
  //   const point = await loyalty.connect(customer1).gettingPointsCompanies(); 
  //   console.log(point);
  // });

  
  
  // it('Should create and list programs properly', async() => {
  //   //creating programs they all valid also 
  //   await loyalty.connect(business1).createProgram("Random", "fsdfsdaf", 200); 
  //   await loyalty.connect(business1).createProgram("loko", "dsfa", 100); 
  //   await loyalty.connect(business1).createProgram("child", "something0", 50);
  //   await loyalty.connect(business1).createProgram("temptation", "dsfa", 100);
  //   let allPrograms = await loyalty.connect(business1).listAllPrograms(); 
  //   console.log(allPrograms); 
  //   console.log("I delete one program "); 
  //   await loyalty.connect(business1).deleteProgram(1); 
  //    allPrograms = await loyalty.connect(business1).listAllPrograms(); 
  //   console.log(allPrograms);
  // });

  it('Should list all avaiable program',async () => {
    
    let validPrograms = await loyalty.connect(customer1).listAvaiablePrograms("Good"); 
    console.log(validPrograms);
  });
  
  
});
