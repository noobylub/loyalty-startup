// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

pragma solidity ^0.8.9;

//for specific details about an item, like who purchased it
//show all the reviews here
contract Item {

}

contract Company is ERC1155 {
    using Counters for Counters.Counter;
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
    //COMPANY GENERAL INFO
   
        address public owner;
        string public name;
        string public contact;
        uint public totalPurchase;
        uint public id;
    

    constructor(
        string memory _name,
        uint _id,
        string memory _contact
    ) ERC1155("https://nftstorage.link/ipfs/${id}") {
       
       owner = msg.sender;
        name = _name;
        contact = _contact;
        totalPurchase = 0;
        id = _id;
    }


    //get all tokens for sale in this market
    //meethod to actually sell them
    //get method to show avaiable exclusive items with their tokens
}

//the method below is just to add points and exchange points
//also to compile everything in one good place
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
    mapping(address => string) idCustomer;

    //POINT TRACK
    mapping(address => mapping(string => uint)) allPoints;

    //COMPANY SHIT
    Counters.Counter private _totalCompanies;
    //IDs by the struct and string
    mapping(uint => Company) companiesId;
    mapping(string => uint) allCompanies;
    mapping(address => uint) addressCompanies;
    

    mapping(uint => mapping(uint => bool)) agree;
    //      FROM  exchange  TO      the rate
    mapping(uint => mapping(uint => uint)) exchange;

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

    //Creating a marketplace so here is the exclusive items
    Counters.Counter private _marketItem;
    //this can be item or services
    struct ExclusiveItem {
        //the id would be _marketitem
        uint id;
        bool services;
        string name;
        uint price;
        string description;
        string companyName;
        address companyAddress;
        uint bought;
        uint pointsAward;
    }

    mapping(uint => ExclusiveItem) allItems;
    mapping(uint => uint[]) requiredTokens;

    //TOKENS IN MARKET
    Counters.Counter private _tokenMarket;
    mapping(uint => marketToken) tokenMarket;
    struct marketToken {
        //owner would be this contract if it is on the market
        address owner;
        //the token id in allTokens
        uint tokenID;
        uint priceMatic;
    }

    // constructor() ERC1155("https://nftstorage.link/ipfs/${id}") {
    //     uint currentToken = _tokenCount.current();
    //     TokenEarn memory firstToken = TokenEarn(
    //         currentToken,
    //         "Good Tokens",
    //         "Owner Company",
    //         msg.sender,
    //         "URI here",
    //         true,
    //         0,
    //         10
    //     );
    //     _mint(msg.sender, currentToken, 20, "");
    //     allTokens[currentToken] = firstToken;
    //     _tokenCount.increment();
    // }

    //token shit
    // function createTokens(
    //     string memory _name,
    //     string memory _uri,
    //     uint _price,
    //     uint _amount,
    //     uint _royalty
    // ) public {
    //     require(
    //         addressCompanies[msg.sender]>0,
    //         "Must be a company owner "
    //     );
    //     uint currentToken = _tokenCount.current();

    //     TokenEarn memory newToken = TokenEarn(
    //         currentToken,
    //         _name,
    //         companiesId[addressCompanies[msg.sender]].name,
    //         msg.sender,
    //         _uri,
    //         true,
    //         _price,
    //         _royalty
    //     );
    //     _mint(msg.sender, currentToken, _amount, "");
    //     allTokens[currentToken] = newToken;
    //     _tokenCount.increment();
    // }

    //called by the company  to list out all of a company's own tokens
    //basically list them out and on click evoke teh more detailed who has these tokens
    function myCompanyTokens() public view returns (TokenEarn[] memory) {
        require(
            companiesId[addressCompanies[msg.sender]].id > 0,
            "Must be a registered company"
        );
        uint max = 0;

        for (uint i = 0; i < _tokenCount.current(); i++) {
            if (allTokens[i].companyAddress == msg.sender) {
                max++;
            }
        }
        TokenEarn[] memory myTokens = new TokenEarn[](max);
        uint current = 0;
        for (uint i = 0; i < _tokenCount.current(); i++) {
            if (allTokens[i].companyAddress == msg.sender) {
                myTokens[current] = allTokens[i];
                current++;
            }
        }
        return myTokens;
    }

    //called by the user to list out all tokens avaible bought for points not matic for
    // a specific company and how much they have
    function listCompanyTokens(string memory whichCompany)
        public
        view
        returns (TokenEarn[] memory, uint[] memory)
    {
        address tokenOwner = companiesId[allCompanies[whichCompany]].owner;
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

    //display the info and all the owners of the token basically the specifics about the token
    function displayWhoHas(uint whichToken)
        public
        view
        returns (string[] memory)
    {
        uint max = 0;
        string[] memory pplAmount = new string[](max);
        for (uint i = 0; i < _personCount.current(); i++) {
            address currentPerson = allPeople[i];
            if (balanceOf(currentPerson, i) > 0) {
                max++;
            }
        }
        uint current = 0;
        for (uint i = 0; i < _personCount.current(); i++) {
            address currentPerson = allPeople[i];
            if (balanceOf(currentPerson, whichToken) > 0) {
                pplAmount[current] = idCustomer[currentPerson];
                current++;
            }
        }
        return pplAmount;
    }

    //transfering tokens from retaile owner to customer
    function transferTokenPoints(uint whichToken) public {
        TokenEarn memory chosenToken = allTokens[whichToken];
        require(
            balanceOf(chosenToken.companyAddress, whichToken) > 0,
            "Not enough from market owner "
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

    //for the company to see all of their products
    //the onclick should have a more detailed overview such as the required tokens
    function returnCompanyItems() public view returns (ExclusiveItem[] memory) {
        uint max = 0;

        for (uint i = 0; i < _marketItem.current(); i++) {
            if (allItems[i].companyAddress == msg.sender) {
                max++;
            }
        }
        ExclusiveItem[] memory myItems = new ExclusiveItem[](max);
        uint current = 0;
        for (uint i = 0; i < _marketItem.current(); i++) {
            if (allItems[i].companyAddress == msg.sender) {
                myItems[current] = allItems[i];
                current++;
            }
        }
        return myItems;
    }

    function itemProductRequirenment(uint i)
        public
        view
        returns (ExclusiveItem memory, uint[] memory)
    {
        return (allItems[i], requiredTokens[i]);
    }

    //Should call displayListTokens() first before passing it for new Item
    //Creates a newmarketplace item or service
    function putNewItem(
        uint[] memory tokensRequire,
        bool _service,
        string memory _name,
        uint _price,
        string memory _description,
        uint _pointsAward
    ) public {
        string memory owner = companiesId[addressCompanies[msg.sender]].name;
        ExclusiveItem memory newItem = ExclusiveItem(
            _marketItem.current(),
            _service,
            _name,
            _price,
            _description,
            owner,
            msg.sender,
            0,
            _pointsAward
        );
        allItems[_marketItem.current()] = newItem;
        requiredTokens[_marketItem.current()] = tokensRequire;
    }

    //display the tokens and their owners which was passed here
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

    //returns two differet type,
    //displays all the items/services for a company and sorts whether possible to buy or not
    //called by the user not customer owner
    function displayCompanyMarket(string memory whichCompany)
        public
        view
        returns (ExclusiveItem[] memory, ExclusiveItem[] memory)
    {
        uint maxAvaiable = 0;
        uint maxUnavaiable = 0;
        address companyToLook = companiesId[allCompanies[whichCompany]].owner;

        for (uint i = 0; i < _marketItem.current(); i++) {
            if (allItems[i].companyAddress == companyToLook) {
                bool isPossible = possibleBuy(i);
                if (isPossible == false) {
                    maxUnavaiable++;
                } else if (isPossible == true) {
                    maxAvaiable++;
                }
            }
        }
        ExclusiveItem[] memory avaiableItems = new ExclusiveItem[](maxAvaiable);
        ExclusiveItem[] memory unavaiableItems = new ExclusiveItem[](
            maxUnavaiable
        );
        uint currentAvaiable = 0;
        uint currentUnavaiable = 0;
        for (uint i = 0; i < _marketItem.current(); i++) {
            if (allItems[i].companyAddress == companyToLook) {
                bool isPossible = possibleBuy(i);
                if (isPossible == false) {
                    avaiableItems[currentAvaiable] = allItems[i];
                    currentAvaiable++;
                } else if (isPossible == true) {
                    unavaiableItems[currentUnavaiable] = allItems[i];
                    currentUnavaiable++;
                }
            }
        }
        return (avaiableItems, unavaiableItems);
    }

    //all the items that user can buy in general with their tokens
    function allUserBuy() public view returns (ExclusiveItem[] memory) {
        uint max = 0;
        for (uint i = 0; i < _marketItem.current(); i++) {
            if (possibleBuy(i) == true) {
                max++;
            }
        }

        ExclusiveItem[] memory items = new ExclusiveItem[](max);
        uint current = 0;
        for (uint i = 0; i < _marketItem.current(); i++) {
            if (possibleBuy(i) == true) {
                items[current] = allItems[i];
                current++;
            }
        }
        return items;
    }

    //Checks whether user can buy that item
    function possibleBuy(uint whichItem) public view returns (bool) {
        bool possible = true;
        for (uint i = 0; i < requiredTokens[whichItem].length; i++) {
            if (balanceOf(msg.sender, requiredTokens[whichItem][i]) <= 0) {
                possible = false;
                break;
            }
        }
        return possible;
    }

    //post purchase method evoked only after the purchase or after possible buy returns to a true;
    function boughtItem(uint whichItem) public {
        allPoints[allItems[whichItem].companyAddress][
            idCustomer[msg.sender]
        ] += allItems[whichItem].pointsAward;
        allItems[whichItem].bought++;
    }

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
        require(allCompanies[_name] == 0);
        require(addressCompanies[msg.sender] == 0);
        _totalCompanies.increment();

        Company newComp = new Company(
            _name,
            _totalCompanies.current(),
            _contact
        );
        allCompanies[_name] = _totalCompanies.current();
        addressCompanies[msg.sender] = _totalCompanies.current();
        companiesId[_totalCompanies.current()] = newComp;
    }

    //for exchanging, companies must both agree
    //this starts it with asking the company for a requests
    function requestPartner(string memory companyRespond) public {
        require(
            companiesId[allCompanies[companyRespond]].id > 0 &&
                companiesId[addressCompanies[msg.sender]].id > 0,
            "Both companies must exist"
        );
        string memory companyRequest = companiesId[addressCompanies[msg.sender]]
            .name;
        agree[allCompanies[companyRequest]][
            allCompanies[companyRespond]
        ] = true;
    }

    //called by the company to see all his requests
    //it works because in order to request one side has to say yes, and if the other has said no then it is a reqeust
    function incomingRequest() public view returns (string[] memory) {
        uint max = 0;
        uint currentCompany = addressCompanies[msg.sender];
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            //first part is the response
            if (
                agree[i][currentCompany] == true &&
                agree[currentCompany][i] != true
            ) {
                max++;
            }
        }
        string[] memory companyPendings = new string[](max);
        uint current = 0;
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            //first part is the response
            if (
                agree[i][currentCompany] == true &&
                agree[currentCompany][i] == false
            ) {
                companyPendings[current] = companiesId[i].name;
            }
        }
        return companyPendings;
    }

    //same thing but the inverse
    function pendingRequest() public view returns (string[] memory) {
        uint max = 0;
        uint currentCompany = addressCompanies[msg.sender];
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            //first part is the response
            if (
                agree[currentCompany][i] == true &&
                agree[currentCompany][i] != true
            ) {
                max++;
            }
        }
        string[] memory companyPendings = new string[](max);
        uint current = 0;
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            //first part is the response
            if (
                agree[currentCompany][i] == true &&
                agree[currentCompany][i] != true
            ) {
                companyPendings[current] = companiesId[i].name;
            }
        }
        return companyPendings;
    }

    //responding to the request
    function requestRespond(bool decision, string memory companyRequest)
        public
    {
        uint companyIDRequest = allCompanies[companyRequest];
        uint companyRespond = addressCompanies[msg.sender];
        //make sure the company actually requested it
        require(
            agree[companyIDRequest][companyRespond] == true,
            "Request does not exist"
        );
        if (decision == true) {
            agree[companyRespond][companyIDRequest] = true;
        } else if (decision == false) {
            agree[companyIDRequest][companyRespond] = false;
        }
    }

    //decides exchange rate called by the company
    function acceptedRate(string memory _exchangeTo, uint howMuchForOne)
        public
    {
        uint myCompany = addressCompanies[msg.sender];
        uint otherCompany = allCompanies[_exchangeTo];
        require(
            agree[myCompany][otherCompany] == true &&
                agree[otherCompany][myCompany] == true,
            "Both party must agree to partner"
        );
        //I would want others to accept my coin as how much
        exchange[otherCompany][myCompany] = howMuchForOne;
    }

    //see how much my coins are exchanging
    //first returns the rate from my company to others company
    //second returnst the rate from the other company to my company
    function displayExchange(string memory _companyExchange)
        public
        view
        returns (uint, uint)
    {
        uint myCompany = addressCompanies[msg.sender];
        uint otherCompany = allCompanies[_companyExchange];
        return (
            exchange[myCompany][otherCompany],
            exchange[otherCompany][myCompany]
        );
    }

    //display all accepted exchanges
    function allExchanges(string memory whichCompany)
        public
        view
        returns (string[] memory)
    {
        uint max = 0;
        for (uint i = 1; i <= _totalCompanies.current(); i++) {
            if (exchange[allCompanies[whichCompany]][i] > 0) {
                max++;
            }
        }
        string[] memory exchanges = new string[](max);
        uint current = 0;
        for (uint i = 1; i <= _totalCompanies.current(); i++) {
            if (exchange[allCompanies[whichCompany]][i] > 0) {
                exchanges[current] = companiesId[i].name;
                current++;
            }
        }
        return exchanges;
    }

    //called by the company
    function allExchanges() public view returns (string[] memory) {
        uint max = 0;
        string memory whichCompany = companiesId[addressCompanies[msg.sender]]
            .name;
        for (uint i = 1; i <= _totalCompanies.current(); i++) {
            if (exchange[allCompanies[whichCompany]][i] > 0) {
                max++;
            }
        }
        string[] memory exchanges = new string[](max);
        uint current = 0;
        for (uint i = 1; i <= _totalCompanies.current(); i++) {
            if (exchange[allCompanies[whichCompany]][i] > 0) {
                exchanges[current] = companiesId[i].name;
                current++;
            }
        }
        return exchanges;
    }

    //The actual exchange
    function exchanging(
        uint amount,
        string memory toWho,
        string memory fromWho
    ) public {
        require(
            exchange[allCompanies[fromWho]][allCompanies[toWho]] > 0,
            "There must be agreed exchanges"
        );
        require(
            allPoints[companiesId[allCompanies[fromWho]].owner][
                idCustomer[msg.sender]
            ] > amount
        );
        uint exchangedAmount = amount *
            exchange[allCompanies[fromWho]][allCompanies[toWho]];
        allPoints[companiesId[allCompanies[fromWho]].owner][
            idCustomer[msg.sender]
        ] -= amount;
        allPoints[companiesId[allCompanies[toWho]].owner][
            idCustomer[msg.sender]
        ] += exchangedAmount;
    }

    //giving points
    //the only people who can give are the owner
    //my point here is for the point of sale after the buyer buys the products
    function givingPoints(uint amount, string memory personTo) public {
        string memory companyName = companiesId[addressCompanies[msg.sender]]
            .name;

        require(
            companiesId[allCompanies[companyName]].owner == msg.sender,
            "Must be registered company"
        );
        address personAddress = personId[personTo];
        require(
            registeredID[personAddress] == true,
            "Must be registered person"
        );
        allPoints[personAddress][companyName] += amount;
    }

    //spending points
    //the customer request
    function spendingPoints(uint pCost, string memory whichCompany)
        public
        returns (bool)
    {
        require(companiesId[allCompanies[whichCompany]].id > 0);
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
            string memory whichCompany = companiesId[i].name;
            if (allPoints[msg.sender][whichCompany] > 0) {
                max++;
            }
        }
        string[] memory personHasPoints = new string[](max);
        uint[] memory personAmountPoints = new uint[](max);
        uint count = 0;
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            //go through each company and if person has point more than zero here, add to the string
            string memory whichCompany = companiesId[i].name;
            if (allPoints[msg.sender][whichCompany] > 0) {
                personHasPoints[count] = whichCompany;
                personAmountPoints[count] = allPoints[msg.sender][whichCompany];
                count++;
            }
        }
        return (personHasPoints, personAmountPoints);
    }
}
