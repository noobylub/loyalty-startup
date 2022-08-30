// describe("Getting Points and Redeeming Points ", () => {
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

//     //gives out points for later
//     await loyalty.connect(business1).givingPoints(200, "better");
//     await loyalty.connect(business2).givingPoints(200, "better");
//     await loyalty.connect(business3).givingPoints(300, "better");
//     await loyalty.connect(business1).givingPoints(200, "Something");
//     await loyalty.connect(business2).givingPoints(200, "Something");
//     await loyalty.connect(business3).givingPoints(300, "Something");
//   });

//   it("Should create some token and have them put to sale", async () => {
//     await loyalty.connect(customer1).transferTokenPoints(1);
//     const { 0: myTokens, 1: amountTokens } = await loyalty
//       .connect(customer1)
//       .showMyToken();

//     console.log("Customer 1");
//     let tokens = [];
//     for (let i = 0; i < myTokens.length; i++) {
//       let item = {
//         tokenID: myTokens[i].tokenID.toNumber(),
//         tokenName: myTokens[i].name,
//         uri: myTokens[i].URI,
//         pointCost: myTokens[i].pricePoints.toNumber(),
//         tokenAmount: amountTokens[i].toNumber(),
//       };
//       tokens.push(item);
//     }
//     console.log(tokens);

//     await loyalty.connect(customer2).transferTokenPoints(1);
//     await loyalty.connect(customer2).transferTokenPoints(4);

//     const { 0: myToken, 1: amountToken } = await loyalty
//       .connect(customer2)
//       .showMyToken();

//     console.log("Customer 2");

//     tokens = [];
//     for (let i = 0; i < myToken.length; i++) {
//       let item = {
//         tokenID: myToken[i].tokenID.toNumber(),
//         tokenName: myToken[i].name,
//         uri: myToken[i].URI,
//         pointCost: myToken[i].pricePoints.toNumber(),
//         tokenAmount: amountToken[i].toNumber(),
//       };
//       tokens.push(item);
//     }
//     console.log(tokens);
//   });
// });

// describe("Catchphrase functinalities", () => {
//   beforeEach(async () => {
//     await loyalty.connect(business1).createCatchPhrase("Something", 50);
//     await loyalty
//       .connect(business1)
//       .createCatchPhrase("Nothing else matters", 50);
//   });
//   it("Catchphrases functions", async () => {
//     console.log(
//       await loyalty.connect(business1).listCatchphraseProgram("Good")
//     );
//     //person redeems catchphrase
//     await loyalty
//       .connect(customer1)
//       .gettingCatchPhrasePoint("Something", "Good");
//     console.log(await loyalty.connect(customer1).gettingDetails("Good"));
//     console.log(
//       await loyalty.connect(business1).listCatchphraseProgram("Good")
//     );
//   });
// });

// it("Should Give out points properly and list them ", async () => {
//   await loyalty.connect(business1).givingPoints(200, "better");
//   await loyalty.connect(business2).givingPoints(200, "better");
//   await loyalty.connect(business3).givingPoints(300, "better");
//   const point = await loyalty.connect(customer1).gettingPointsCompanies();
//   console.log(point);
// });

// describe("varities of program functions", () => {
//   beforeEach(async () => {
//     //creates program to purchase
//     await loyalty.connect(business1).createProgram("Random", "fsdfsdaf", 200); //0
//     await loyalty.connect(business2).createProgram("loko", "dsfa", 100); //1
//     await loyalty.connect(business1).createProgram("child", "something0", 50); //2
//     await loyalty.connect(business2).createProgram("temptation", "dsfa", 100); //3
//     await loyalty
//       .connect(business1)
//       .createProgram("Nevermind This", "desribe", 100); //4
//     await loyalty.connect(business2).createProgram("Another name", "dsfa", 300); //5
//     await loyalty.connect(business3).createProgram("FIRED", "dsfa", 300); //6
//   });
//   it("should delete properly despite multiple owners", async () => {
//     //creating programs they all valid also
//     let allPrograms = await loyalty.connect(business2).listAllPrograms();
//     let programs = allPrograms.map((i) => {
//       let program = {
//         "Program Name": i.programName,
//         id: i.numberId.toNumber(),
//         owner: i.owner,
//         "Company Owner": i.ownerName,
//         "Point Cost": i.cost.toNumber(),
//         Description: i.ipfsDescription,
//       };
//       return program;
//     });
//     console.log("Before deletion");
//     console.log(programs);
//     console.log("after deletion ");
//     await loyalty.connect(business1).deleteProgram(1);
//     allPrograms = await loyalty.connect(business2).listAllPrograms();
//     programs = allPrograms.map((i) => {
//       let program = {
//         "Program Name": i.programName,
//         id: i.numberId.toNumber(),
//         owner: i.owner,
//         "Company Owner": i.ownerName,
//         "Point Cost": i.cost.toNumber(),
//         Description: i.ipfsDescription,
//       };
//       return program;
//     });
//     console.log(programs);
//     allPrograms = await loyalty.connect(business3).listAllPrograms();
//     programs = allPrograms.map((i) => {
//       let program = {
//         "Program Name": i.programName,
//         id: i.numberId.toNumber(),
//         owner: i.owner,
//         "Company Owner": i.ownerName,
//         "Point Cost": i.cost.toNumber(),
//         Description: i.ipfsDescription,
//       };
//       return program;
//     });
//     console.log(programs);
//   });
//   it("should turn program on and off", async () => {
//     console.log("All programs for business2 named some");
//     allPrograms = await loyalty.connect(customer1).listAvaiablePrograms("Some");
//     programs = allPrograms.map((i) => {
//       let program = {
//         "Program Name": i.programName,
//         id: i.numberId.toNumber(),
//         owner: i.owner,
//         "Company Owner": i.ownerName,
//         "Point Cost": i.cost.toNumber(),
//         Description: i.ipfsDescription,
//       };
//       return program;
//     });
//     console.log(programs);
//     console.log(
//       "All programs for business2 named some after turning off program with id 1"
//     );
//     await loyalty.connect(business2).turnOffProgram(1);
//     allPrograms = await loyalty.connect(business2).listAvaiablePrograms("Some");
//     programs = allPrograms.map((i) => {
//       let program = {
//         "Program Name": i.programName,
//         id: i.numberId.toNumber(),
//         owner: i.owner,
//         "Company Owner": i.ownerName,
//         "Point Cost": i.cost.toNumber(),
//         Description: i.ipfsDescription,
//       };
//       return program;
//     });
//     console.log(programs);
//     await loyalty.connect(business3).turnOffProgram(6);
//   });
//   it("Should list all avaiable program and buy one", async () => {
//     console.log("Nothing here");
//     let validPrograms = await loyalty.connect(customer1).allMyPrograms();
//     let allProgram = validPrograms.map((i) => {
//       let program = {
//         "Program Name": i.programName,
//         id: i.numberId.toNumber(),
//         owner: i.owner,
//         "Company Owner": i.ownerName,
//         "Point Cost": i.cost.toNumber(),
//         Description: i.ipfsDescription,
//       };
//       return program;
//     });
//     console.log(allProgram);
//     //spending money on one program
//     console.log("spending money on program");
//     await loyalty.connect(customer1).enterProgram(3);
//     await loyalty.connect(customer1).enterProgram(4);
//     const compani = [];
//     const { 0: companies, 1: points } = await loyalty
//       .connect(customer1)
//       .gettingPointsCompanies();
//     for (let i = 0; i < companies.length; i++) {
//       let item = {
//         company: companies[i],
//         amount: points[i].toNumber(),
//       };
//       compani.push(item);
//     }
//     console.log(compani);
//     validPrograms = await loyalty.connect(customer1).allMyPrograms();
//     allProgram = validPrograms.map((i) => {
//       let program = {
//         "Program Name": i.programName,
//         id: i.numberId.toNumber(),
//         owner: i.owner,
//         "Company Owner": i.ownerName,
//         "Point Cost": i.cost.toNumber(),
//         Description: i.ipfsDescription,
//       };
//       return program;
//     });
//     console.log(allProgram);
//   });
// });
