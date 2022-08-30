// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

pragma solidity ^0.8.9;

contract Loyalty is ERC1155 {
    using Counters for Counters.Counter;

    //ALL CUSTOMER SHIT 
    //for iterating just to check some things
    Counters.Counter private _personCount;
    mapping(uint => address) allPeople;
    //customer so no duplicates 
    mapping(string => bool) idExist;
    mapping(address => bool) registeredID;
    //customer id
    mapping(string => address) personId;
    mapping(address => string)idCustomer;
    

    //POINT TRACK
    mapping(address => mapping(string => uint)) allPoints;

    // //PROGRAM SHIT 
    // Counters.Counter private _programCount;
    // Counters.Counter private _idPeopleEntered;
    // //mapping(string => mapping(uint => mapping(address => bool))) programEntered;
    // mapping(uint => mapping(address => bool)) peopleEntered;
    // mapping(uint => PointProgram) allPrograms;
    // struct PointProgram {
    //     uint numberId;
    //     address owner;
    //     string ownerName;
    //     uint cost;
    //     string ipfsDescription;
    //     bool valid;
    //     string programName;
    //     uint idPeopleEnter;
    // }

    //CATCHPHRASES TO ENTER FOR POINTS 
    mapping(string => mapping(string => uint)) catchphraseProgram;
    mapping(string => string[]) phraseExist;
    mapping(string => mapping(string => uint)) phraseExistIndex;

    //COMPANY SHIT
    Counters.Counter private _totalCompanies;
    //IDs by the struct and string
    mapping(uint => string) companiesId;
    mapping(string => Company) allCompanies;
    mapping(address => Company) addressCompanies;
    struct Company {
        address owner;
        string name;
        string contact;
        uint totalPurchase;
        uint discount;
        uint id;
    }

    //TOKEN INFO SHIT 
    Counters.Counter private _tokenCount;
    mapping(uint => TokenEarn) allTokens;
    struct TokenEarn {
        uint tokenID;
        string name;
        string companyName;
        address companyAddress;
        string URI;
        bool valid;
        uint pricePoints;
        uint royalty;
    }

    //TOKENS IN MARKET
    Counters.Counter private _marketCount;
    mapping(uint => marketToken) tokenMarket;
    struct marketToken {
        //owner would be this contract if it is on the market
        address owner;
        //the token id in allTokens
        uint tokenID;
        uint priceMatic;
    }

    //EXCLUSIVE BENEFIT FOR TOKENS 
    Counters.Counter private benefitCount;
    mapping(uint => provideBenefit) allBenefits;
    struct provideBenefit {
        string companyOwner;
        uint numberBenefits;
        uint supportingCompanies;
    }
    mapping(uint => mapping(uint => bool)) validTokens;
    mapping(uint => mapping(uint => string)) companyBenefits;
    //for Partner companies, it points to a URI
    mapping(uint => mapping(uint => string)) supportingCompanies;

    constructor() ERC1155("https://nftstorage.link/ipfs/${id}") {
        uint currentToken = _tokenCount.current();
        TokenEarn memory firstToken = TokenEarn(
            currentToken,
            "Good Tokens",
            "Owner Company",
            msg.sender,
            "URI here",
            true,
            0,
            10
        );
        _mint(msg.sender, currentToken, 20, "");
        allTokens[currentToken] = firstToken;
        _tokenCount.increment();
    }

    //token shit
    function createTokens(
        string memory _name,
        string memory _uri,
        uint _price,
        uint _amount,
        uint _royalty
    ) public {
        require(
            addressCompanies[msg.sender].id > 0,
            "Must be a company owner "
        );
        uint currentToken = _tokenCount.current();

        TokenEarn memory newToken = TokenEarn(
            currentToken,
            _name,
            addressCompanies[msg.sender].name,
            msg.sender,
            _uri,
            true,
            _price,
            _royalty
        );
        _mint(msg.sender, currentToken, _amount, "");
        allTokens[currentToken] = newToken;
        _tokenCount.increment();
    }

    //called by the company  to list out all of their own tokens 
    function myCompanyTokens()public view returns(TokenEarn[] memory) {
        require(addressCompanies[msg.sender].id > 0, "Must be a registered company"); 
        uint max =0; 
         
        for(uint i=0; i< _tokenCount.current(); i++){
            if(allTokens[i].companyAddress == msg.sender){
                max++;
            }
        }
        TokenEarn[] memory myTokens = new TokenEarn[](max);
        uint current = 0; 
        for(uint i=0; i< _tokenCount.current(); i++){
            if(allTokens[i].companyAddress == msg.sender){
                myTokens[current] = allTokens[i];
                current++; 
            }
        }
        return myTokens; 
    }

    //called by the user to list out all tokens avaible bought for points not matic
    function listCompanyTokens(string memory whichCompany)
        public
        view
        returns (TokenEarn[] memory, uint[] memory)
    {
        address tokenOwner = allCompanies[whichCompany].owner;
        uint max = 0;
        for (uint i = 0; i < _tokenCount.current(); i++) {
            if (
                allTokens[i].companyAddress == tokenOwner &&
                allTokens[i].valid == true
            ) {
                max++;
            }
        }
        TokenEarn[] memory companyTokens = new TokenEarn[](max);
        uint[] memory balances = new uint[](max);
        uint count = 0;
        for (uint i = 0; i < _tokenCount.current(); i++) {
            if (
                allTokens[i].companyAddress == tokenOwner &&
                allTokens[i].valid == true
            ) {
                companyTokens[count] = allTokens[i];
                balances[count] = balanceOf(allTokens[i].companyAddress, i);
                count++;
            }
        }
        return (companyTokens, balances);
    }

    //transfering tokens from retaile owner to customer
    function transferTokenPoints(uint whichToken) public {
        TokenEarn memory chosenToken = allTokens[whichToken];
        require(
            balanceOf(chosenToken.companyAddress, whichToken) > 0,
            "Must purchase through market, "
        );
        require(
            allPoints[msg.sender][chosenToken.companyName] >=
                chosenToken.pricePoints,
            "You must have enought points"
        );

        allPoints[msg.sender][chosenToken.companyName] -= chosenToken
            .pricePoints;
        _safeTransferFrom(
            chosenToken.companyAddress,
            msg.sender,
            whichToken,
            1,
            ""
        );
    }

    //list users of his own tokens
    function showMyToken()
        public
        view
        returns (TokenEarn[] memory, uint[] memory)
    {
        uint max = 0;
        require(registeredID[msg.sender] == true, "You must be a customer");
        for (uint i = 0; i < _tokenCount.current(); i++) {
            if (balanceOf(msg.sender, i) > 0) {
                max++;
            }
        }
        TokenEarn[] memory myTokens = new TokenEarn[](max);
        uint[] memory balances = new uint[](max);
        uint count = 0;
        for (uint i = 0; i < _tokenCount.current(); i++) {
            if (balanceOf(msg.sender, i) > 0) {
                myTokens[count] = allTokens[i];
                balances[count] = balanceOf(msg.sender, i);
                count++;
            }
        }
        return (myTokens, balances);
    }

    //display the info and owner of the token
    function displayWhoHas(uint whichToken) public view returns(string[] memory){
        uint max =0;
        string[] memory pplAmount = new string[](max);
        for (uint i = 0; i < _personCount.current(); i++) {
            address currentPerson = allPeople[i];
            if (balanceOf(currentPerson, i) > 0) {
                max++;
            }
        }
        uint current =0; 
        for (uint i = 0; i < _personCount.current(); i++) {
            address currentPerson = allPeople[i];
            if (balanceOf(currentPerson, whichToken) > 0) {
                pplAmount[current] = idCustomer[currentPerson];
                current++; 
            }
        }
        return pplAmount; 
    }

    //display the tokens and their owners
    function displayListTokens(uint[] memory whichTokens)
        public
        view
        returns (TokenEarn[] memory)
    {
        bool allowed = true;
        for (uint i = 0; i < whichTokens.length; i++) {
            if (whichTokens[i] >= _tokenCount.current()) {
                allowed = false;
            }
        }
        require(allowed == true, "Must be valid tokens");

        TokenEarn[] memory theseTokens = new TokenEarn[](whichTokens.length);
        for (uint i = 0; i < whichTokens.length; i++) {
            theseTokens[i] = allTokens[whichTokens[i]];
        }
        return theseTokens;
    }

    //some people might want multiple tokens to unlock program
    //create benefit program with the tokens
    //put all of these tokens and evoke a method that display all of these tokens
    function createBenefit(uint[] memory whichToken) public {
        bool tokenEligible = true;
        for (uint i = 0; i < whichToken.length; i++) {
            //only allow valid tokens to create new benefit
            if (allTokens[whichToken[i]].valid == false) {
                tokenEligible = false;
            }
        }

        require(tokenEligible == true, "inelligible string");

        //require(addressExistsCompany[msg.sender] == true);
        require(addressCompanies[msg.sender].id > 0, "Must be valid company");
        //string memory companyName = idToNameCompany[msg.sender];
        provideBenefit memory newBenefit = provideBenefit(
            addressCompanies[msg.sender].name,
            0,
            0
        );
        allBenefits[benefitCount.current()] = newBenefit;
        for (uint i = 0; i < whichToken.length; i++) {
            validTokens[benefitCount.current()][whichToken[i]] = true;
        }
        benefitCount.increment();
    }

    //shows all the benefit programs for the company 
    function listExclusivePrograms()public view returns(provideBenefit[] memory){
        uint max =0 ;
        for(uint i=0 ;i<benefitCount.current(); i++){
            if(allCompanies[allBenefits[i].companyOwner].owner == msg.sender){
                max++;
            } 
        }
        provideBenefit[] memory myPrograms = new provideBenefit[](max);
        uint current = 0;
        for(uint i=0 ;i<benefitCount.current(); i++){
            if(allCompanies[allBenefits[i].companyOwner].owner == msg.sender){
                myPrograms[current] = allBenefits[i]; 
                current++; 
            } 
        }
        return myPrograms;
    }

    //add benefits for the company that create the program
    function addBenefits(string memory URIBenefit, uint whichProgram) public {
        allBenefits[whichProgram].numberBenefits++;
        uint noBenefit = allBenefits[whichProgram].numberBenefits;
        companyBenefits[whichProgram][noBenefit] = URIBenefit;
    }

    //show the benefits from that program
    function showBenefit(uint whichProgram)
        public
        view
        returns (string[] memory benefits)
    {
        uint noBenefit = allBenefits[whichProgram].numberBenefits;

        string[] memory thisBenefit = new string[](noBenefit);
        uint count = 0;
        for (uint i = 1; i <= noBenefit; i++) {
            thisBenefit[count] = companyBenefits[whichProgram][i];
            count++;
        }
        return thisBenefit;
    }

    //this is the partner adding benefit themselves to a benefit program .
    // function addCompanyBenefit(string memory _benefit, uint whichToken)
    //     public
    // {

    // }

    function registerCustomer(string memory _name) public {
        require(idExist[_name] == false, "Name already taken");
        //require so that not one eth address can register multiple times
        require(
            registeredID[msg.sender] == false,
            "already registered with address, please log in"
        );
        registeredID[msg.sender] = true;
        idExist[_name] = true;
        personId[_name] = msg.sender;
        idCustomer[msg.sender] = _name; 
        allPeople[_personCount.current()] = msg.sender;
        _personCount.increment();
    }

    //registers company
    function registerCompany(string memory _name, string memory _contact)
        public
    {
        require(addressCompanies[msg.sender].id == 0);
        require(allCompanies[_name].id == 0);
        _totalCompanies.increment();
        Company memory newComp;
        newComp.owner = msg.sender;
        newComp.name = _name;
        newComp.contact = _contact;
        newComp.totalPurchase = 0;
        newComp.id = _totalCompanies.current();

        allCompanies[_name] = newComp;
        addressCompanies[msg.sender] = newComp;
        companiesId[_totalCompanies.current()] = _name;
    }

    //giving points
    //the only people who can give are the owner
    //my point here is for the point of sale after the buyer buys the products
    function givingPoints(uint amount, string memory personTo) public {
        string memory companyName = addressCompanies[msg.sender].name;

        require(allCompanies[companyName].owner == msg.sender, "Must be registered company");
        address personAddress = personId[personTo];
        require(registeredID[personAddress] == true, "Must be registered person");
        allPoints[personAddress][companyName] += amount;
    }

    // //Company creating a catchphrase for handing Points .
    function createCatchPhrase(string memory catchphrase, uint _pointAmount)
        public
    {
        string memory whichCompany = addressCompanies[msg.sender].name;

        require(_pointAmount > 0, "Must be greater than zero");
        require(allCompanies[whichCompany].owner == msg.sender);
        //designs a secret catchphrase that user would hvae to find out.
        catchphraseProgram[whichCompany][catchphrase] = _pointAmount;
        phraseExist[whichCompany].push(catchphrase);
        phraseExistIndex[whichCompany][catchphrase] =
            phraseExist[whichCompany].length -
            1;
    }

    //redeeming program will also lead to deletion of the specific catchphrase
    function gettingCatchPhrasePoint(
        string memory programName,
        string memory whichCompany
    ) public {
        require(
            allCompanies[whichCompany].id > 0,
            "Must be a registered company"
        );
        require(
            catchphraseProgram[whichCompany][programName] > 0,
            "Catchphrase does not exist"
        );
        allPoints[msg.sender][whichCompany] += catchphraseProgram[whichCompany][
            programName
        ];
        catchphraseProgram[whichCompany][programName] = 0;

        uint indexRedeemed = phraseExistIndex[whichCompany][programName];
        if (indexRedeemed == phraseExist[whichCompany].length) {
            phraseExist[whichCompany].pop();
        } else {
            phraseExist[whichCompany][indexRedeemed] = phraseExist[
                whichCompany
            ][phraseExist[whichCompany].length - 1];
            phraseExistIndex[whichCompany][
                phraseExist[whichCompany][indexRedeemed]
            ] = indexRedeemed;
            phraseExist[whichCompany].pop();
        }
    }

    //list of all the program catchprases
    function listCatchphraseProgram(string memory whichCompany)
        public
        view
        returns (string[] memory)
    {
        require(
            keccak256(abi.encodePacked((addressCompanies[msg.sender].name))) ==
                keccak256(abi.encodePacked((whichCompany))),
            "You must be the owner of the Company"
        );
        return phraseExist[whichCompany];
    }

    //program shit
    //program to send points
    // function createProgram(
    //     string memory _programName,
    //     string memory _description,
    //     uint _cost
    // ) public {
    //     require(
    //         addressCompanies[msg.sender].id > 0,
    //         "Company must be registered"
    //     );
    //     string memory whichCompany = addressCompanies[msg.sender].name;
    //     uint currentNumber = _programCount.current();
    //     uint idPeopleEnter = _idPeopleEntered.current();
    //     PointProgram memory newProgram = PointProgram(
    //         currentNumber,
    //         msg.sender,
    //         whichCompany,
    //         _cost,
    //         _description,
    //         true,
    //         _programName,
    //         idPeopleEnter
    //     );
    //     allPrograms[currentNumber] = newProgram;
    //     _idPeopleEntered.increment();
    //     _programCount.increment();
    // }

    // function enterProgram(uint _idProgram) public {
    //     require(
    //         _idProgram < _programCount.current(),
    //         "Impossible, program does not exist"
    //     );
    //     uint idPersonEnter = allPrograms[_idProgram].idPeopleEnter;
    //     uint cost = allPrograms[_idProgram].cost;
    //     allPoints[msg.sender][allPrograms[_idProgram].ownerName] -= cost;
    //     peopleEntered[idPersonEnter][msg.sender] = true;
    // }

    // //did not
    // function allMyPrograms() public view returns (PointProgram[] memory) {
    //     uint max = 0;
    //     for (uint i = 0; i < _programCount.current(); i++) {
    //         uint idPersonEnter = allPrograms[i].idPeopleEnter;
    //         if (peopleEntered[idPersonEnter][msg.sender] == true) {
    //             max++;
    //         }
    //     }

    //     PointProgram[] memory myPrograms = new PointProgram[](max);
    //     uint count = 0;
    //     for (uint i = 0; i < _programCount.current(); i++) {
    //         uint idPersonEnter = allPrograms[i].idPeopleEnter;
    //         if (peopleEntered[idPersonEnter][msg.sender] == true) {
    //             myPrograms[count] = allPrograms[i];
    //             count++;
    //         }
    //     }
    //     return myPrograms;
    // }

    // //only the program owner can turn off program
    // function turnOffProgram(uint idProgram) public {
    //     require(
    //         allPrograms[idProgram].owner == msg.sender,
    //         "Must be contract owner"
    //     );
    //     allPrograms[idProgram].valid = false;
    // }

    // function turnOnProgram(uint idProgram) public {
    //     require(allPrograms[idProgram].owner == msg.sender);
    //     allPrograms[idProgram].valid = true;
    // }

    // //This should really be looked down upon, as what would happen to customers who originally listed here
    // function deleteProgram(uint idDelete) public {
    //     if (idDelete == _programCount.current() - 1) {
    //         _programCount.decrement();
    //     } else {
    //         allPrograms[idDelete] = allPrograms[_programCount.current() - 1];
    //         allPrograms[idDelete].numberId = idDelete;
    //         _programCount.decrement();
    //     }
    // }

    // //did not
    // //the only one who can redeem program are the owners of the store
    // function redeemProgram(uint _idProgram, string memory personRedeeming)
    //     public
    // {
    //     address person = personId[personRedeeming];
    //     PointProgram memory redeemThis = allPrograms[_idProgram];
    //     uint idPerson = allPrograms[_idProgram].idPeopleEnter;
    //     require(
    //         redeemThis.owner == msg.sender,
    //         "You need to be the owner of the program"
    //     );
    //     require(
    //         peopleEntered[idPerson][person] == true,
    //         "Person does not have this program"
    //     );
    //     peopleEntered[idPerson][person] = false;
    // }

    // //list all programs by the company
    // function listAllPrograms() public view returns (PointProgram[] memory) {
    //     require(addressCompanies[msg.sender].id > 0, "Company must exist");
    //     uint max = 0;
    //     for (uint i = 0; i < _programCount.current(); i++) {
    //         if (allPrograms[i].owner == msg.sender) {
    //             max++;
    //         }
    //     }
    //     PointProgram[] memory listingAllProgram = new PointProgram[](max);
    //     uint count = 0;
    //     for (uint i = 0; i < _programCount.current(); i++) {
    //         if (allPrograms[i].owner == msg.sender) {
    //             listingAllProgram[count] = allPrograms[i];
    //             count++;
    //         }
    //     }
    //     return listingAllProgram;
    // }

    // //did not
    // //called by the users to list all programs for a company
    // function listAvaiablePrograms(string memory whichCompany)
    //     public
    //     view
    //     returns (PointProgram[] memory)
    // {
    //     uint max = 0;
    //     for (uint i = 0; i < _programCount.current(); i++) {
    //         if (
    //             keccak256(bytes(allPrograms[i].ownerName)) ==
    //             keccak256(bytes(whichCompany)) &&
    //             allPrograms[i].valid == true
    //         ) {
    //             max++;
    //         }
    //     }
    //     PointProgram[] memory validPrograms = new PointProgram[](max);
    //     uint count = 0;
    //     for (uint i = 0; i < _programCount.current(); i++) {
    //         if (
    //             keccak256(bytes(allPrograms[i].ownerName)) ==
    //             keccak256(bytes(whichCompany)) &&
    //             allPrograms[i].valid == true
    //         ) {
    //             validPrograms[count] = allPrograms[i];
    //             count++;
    //         }
    //     }
    //     return validPrograms;
    // }

    //spending points
    //the customer request
    function spendingPoints(uint pCost, string memory whichCompany)
        public
        returns (bool)
    {
        require(allCompanies[whichCompany].id > 0);
        require(
            pCost <= allPoints[msg.sender][whichCompany],
            "Needs more points"
        );
        allPoints[msg.sender][whichCompany] -= pCost;

        return true;
    }

    //getting details about points
    //getting points for each company
    function gettingDetails(string memory whichCompany)
        public
        view
        returns (uint)
    {
        return allPoints[msg.sender][whichCompany];
    }

    //remember this when reading multiple values https://blockheroes.dev/js-read-multiple-returned-values-solidity/
    function gettingPointsCompanies()
        public
        view
        returns (string[] memory, uint[] memory)
    {
        uint max = 0;
        for (uint i = 1; i <= _totalCompanies.current(); i++) {
            string memory whichCompany = companiesId[i];
            if (allPoints[msg.sender][whichCompany] > 0) {
                max++;
            }
        }
        string[] memory personHasPoints = new string[](max);
        uint[] memory personAmountPoints = new uint[](max);
        uint count = 0;
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            //go through each company and if person has point more than zero here, add to the string
            string memory whichCompany = companiesId[i];
            if (allPoints[msg.sender][whichCompany] > 0) {
                personHasPoints[count] = whichCompany;
                personAmountPoints[count] = allPoints[msg.sender][whichCompany];
                count++;
            }
        }
        return (personHasPoints, personAmountPoints);
    }
}
