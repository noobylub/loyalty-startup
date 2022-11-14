// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

pragma solidity ^0.8.9;

contract Company is ERC1155 {
    using Counters for Counters.Counter;
    //TOKEN INFO SHIT
    Counters.Counter private _tokenCount;
    mapping(uint => TokenEarn) allTokens;
    struct TokenEarn {
        uint tokenID;
        uint companyID;
        string name;
        string companyName;
        address companyAddress;
        string imageURL;
        bool valid;
        uint pricePoints;
        uint royalty;
    }

    //Just Customers and kind of like display previous token holders
    Counters.Counter private _customerCount;
    mapping(uint => address) allCustomers;

    Loyalty mainContract; 

    //Creating a marketplace so here is the exclusive items
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
    Counters.Counter private _marketItem;
    mapping(uint => ExclusiveItem) allItems;
    mapping(uint => uint[]) requiredTokens;

    //COMPANY GENERAL INFO
    address private generalContract;
    address public owner;
    string public name;
    string public contact;
    uint public totalPurchase;
    uint public id;
    string public stripeID;

    //Tokens reselling
    mapping(uint => MarketToken) marketItems;
    Counters.Counter private _totalMarket;
    struct MarketToken {
        address payable owner;
        uint tokenID;
        uint price;
        uint amount;
    }

    //points tracking
    mapping(address => uint) public allPoints;

    //constructor
    constructor(
        string memory _name,
        uint _id,
        string memory _contact,
        address _contractOwner,
        string memory _stripeID,
        Loyalty _mainContract
    ) ERC1155("https://nftstorage.link/ipfs/${id}") {
        generalContract = _contractOwner;
        owner = msg.sender;
        name = _name;
        contact = _contact;
        totalPurchase = 0;
        id = _id;
        stripeID = _stripeID;
        mainContract = _mainContract;
    }

    function givingPoints(string memory toWho, uint amount)public {
        
        require(mainContract.customerNames(toWho) > 0); 
        require(msg.sender == owner); 
        address customerAdd = mainContract.showCustomer(toWho).customerAddress;
        allPoints[customerAdd] += amount; 
    }

    //creates some tokens for the company
    function createTokens(
        string memory _name,
        uint _companyID,
        string memory _uri,
        uint _price,
        uint _amount,
        uint _royalty
    ) public {
        require(msg.sender == owner);
        uint currentToken = _tokenCount.current();

        TokenEarn memory newToken = TokenEarn(
            currentToken,
            _companyID,
            _name,
            name,
            owner,
            _uri,
            true,
            _price,
            _royalty
        );
        _mint(msg.sender, currentToken, _amount, "");
        allTokens[currentToken] = newToken;
        _tokenCount.increment();
    }

    //Show all of the company Tokens
    function companyTokens() public view returns (TokenEarn[] memory) {
        require(msg.sender == owner); 
        TokenEarn[] memory myTokens = new TokenEarn[](_tokenCount.current());
        for (uint i = 0; i < myTokens.length; i++) {
            myTokens[i] = allTokens[i];   
        }
        return myTokens;
    }

    //shows the tokens avaiable to buy by points and how much there is to sell
    function showsTokenPoints()
        public
        view
        returns (TokenEarn[] memory, uint[] memory)
    {
        uint max = 0;
        for (uint i = 0; i < _tokenCount.current(); i++) {
            if (balanceOf(owner, i) > 0) {
                max++;
            }
        }

        TokenEarn[] memory myTokens = new TokenEarn[](max);
        uint[] memory allAmounts = new uint[](max);
        uint current = 0;
        for (uint i = 0; i < allAmounts.length; i++) {
            if (balanceOf(owner, i) > 0) {
                myTokens[current] = allTokens[i];
                allAmounts[current] = balanceOf(owner, i);
                current++;
            }
        }
        return (myTokens, allAmounts);
    }

    //sells token by the points
    function tokenBuyPoints(uint whichToken, uint amount) public {
        require(balanceOf(owner, whichToken) > 0, "Unavaible tokens");
        require(
            allPoints[msg.sender] > amount * allTokens[whichToken].pricePoints,
            "Not enough points"
        );
        allCustomers[_customerCount.current()] = msg.sender;
        _customerCount.increment();
        allPoints[msg.sender] -= amount * allTokens[whichToken].pricePoints;
        _safeTransferFrom(owner, msg.sender, whichToken, amount, "");
    }

    //shows the tokens that the user has
    function showMyToken()
        public
        view
        returns (TokenEarn[] memory, uint[] memory)
    {
        uint max = 0;

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

    //display all the owners of the token in address which can be converted in the main contract
    function displayWhoHas(uint whichToken)
        public
        view
        returns (address[] memory)
    {
        uint max = 0;

        for (uint i = 0; i < _customerCount.current(); i++) {
            address currentPerson = allCustomers[i];
            if (balanceOf(currentPerson, i) > 0) {
                max++;
            }
        }
        uint current = 0;
        address[] memory pplAmount = new address[](max);
        for (uint i = 0; i < _customerCount.current(); i++) {
            address currentPerson = allCustomers[i];
            if (balanceOf(currentPerson, whichToken) > 0) {
                pplAmount[current] = allCustomers[i];
                current++;
            }
        }
        return pplAmount;
    }

    //puts the tokens in the market with matic
    function putMarket(
        uint whichToken,
        uint amount,
        uint _price
    ) public {
        require(whichToken < _tokenCount.current());
        MarketToken memory newMarket = MarketToken(
            payable(msg.sender),
            whichToken,
            _price,
            amount
        );
        marketItems[_totalMarket.current()] = newMarket;
        _safeTransferFrom(msg.sender, generalContract, whichToken, amount, "");
        _totalMarket.increment();
    }

    //list all market items for this company
    function listMarket()
        public
        view
        returns (
            TokenEarn[] memory,
            uint[] memory price,
            uint[] memory amount
        )
    {
        TokenEarn[] memory marketTokens = new TokenEarn[](
            _totalMarket.current()
        );
        uint[] memory prices = new uint[](_totalMarket.current());
        uint[] memory amounts = new uint[](_totalMarket.current());
        for (uint i = 0; i < _totalMarket.current(); i++) {
            marketTokens[i] = allTokens[marketItems[i].tokenID];
            prices[i] = marketItems[i].price;
            amounts[i] = marketItems[i].amount;
        }
        return (marketTokens, prices, amounts);
    }

    //sold the Tokens
    function soldToken(uint whichMarketItems) public payable {
        require(
            msg.value >= marketItems[whichMarketItems].price,
            "Required Price"
        );
        _safeTransferFrom(
            generalContract,
            msg.sender,
            marketItems[whichMarketItems].tokenID,
            marketItems[whichMarketItems].amount,
            ""
        );
        marketItems[whichMarketItems].owner.transfer(msg.value);
        marketItems[whichMarketItems] = marketItems[_totalMarket.current() - 1];
        _totalMarket.decrement();
    }

    //Should call displayListTokens() first before passing it for new Item to see about the specifics of the tokens
    //Creates a newmarketplace item or service
    function putNewItem(
        uint[] memory tokensRequire,
        bool _service,
        string memory _name,
        uint _price,
        string memory _description,
        uint _pointsAward
    ) public {
        require(msg.sender == owner);
        ExclusiveItem memory newItem = ExclusiveItem(
            _marketItem.current(),
            _service,
            _name,
            _price,
            _description,
            name,
            owner,
            0,
            _pointsAward
        );
        allItems[_marketItem.current()] = newItem;
        requiredTokens[_marketItem.current()] = tokensRequire;
        _marketItem.increment();
    }

    //display all the tokens by number id and more info about them
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
    //displays all the items/services for a company and sorts whether possible to buy or not with the tokens the user has
    //called by the user not customer owner
    function displayCompanyMarket()
        public
        view
        returns (ExclusiveItem[] memory, ExclusiveItem[] memory)
    {
        uint maxAvaiable = 0;
        uint maxUnavaiable = 0;

        for (uint i = 0; i < _marketItem.current(); i++) {
            bool possible = possibleBuy(i);
            if (possible) {
                maxAvaiable++;
            } else if (!possible) {
                maxUnavaiable++;
            }
        }
        ExclusiveItem[] memory avaiableItems = new ExclusiveItem[](maxAvaiable);
        ExclusiveItem[] memory unavaiableItems = new ExclusiveItem[](
            maxUnavaiable
        );
        uint currentAvaiable = 0;
        uint currentUnavaiable = 0;
        for (uint i = 0; i < _marketItem.current(); i++) {
            bool isPossible = possibleBuy(i);
            if (isPossible == false) {
                avaiableItems[currentAvaiable] = allItems[i];
                currentAvaiable++;
            } else if (isPossible == true) {
                unavaiableItems[currentUnavaiable] = allItems[i];
                currentUnavaiable++;
            }
        }
        return (avaiableItems, unavaiableItems);
    }
    //has to be a registered customer 
    function displayPossibleBuy() public view returns (ExclusiveItem[] memory) {
        //uint x = Loyalty.customerAddress(msg.sender);
        require(mainContract.customerAddress(msg.sender) > 0);
        uint maxAvaiable = 0;

        for (uint i = 0; i < _marketItem.current(); i++) {
            bool possible = possibleBuy(i);
            if (possible) {
                maxAvaiable++;
            }
        }
        ExclusiveItem[] memory avaiableItems = new ExclusiveItem[](maxAvaiable);

        uint currentAvaiable = 0;

        for (uint i = 0; i < _marketItem.current(); i++) {
            bool isPossible = possibleBuy(i);
            if (isPossible == false) {
                avaiableItems[currentAvaiable] = allItems[i];
                currentAvaiable++;
            }
        }
        return (avaiableItems);
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

    //the way it works is that the merchant sets item price in dollars but people buy in crypto
    //post purchase method evoked only after the purchase or after possible buy returns to a true;
    function boughtItem(uint whichItem) public {
        
        allPoints[msg.sender] += allItems[whichItem].pointsAward;
        allItems[whichItem].bought++;
    }

    
}

contract Loyalty {
    using Counters for Counters.Counter;
    address owner;

    Counters.Counter private _totalCompanies;
    mapping(uint => Company) public allCompanies;
    mapping(string => uint) allNames;
    mapping(address => uint) allAddress;
    struct CompanyView {
        address owner;
        string name;
        string contact;
        uint id;
        uint balance;
    }
    //customer display 
    struct Customer{
        uint customerID; 
        string name;
        address customerAddress; 
        string stripeID;
    }
    Counters.Counter private _totalCustomer; 
    mapping(uint => Customer)public allCustomers; 
    mapping(string => uint)public customerNames; 
    mapping(address => uint)public customerAddress; 

    //ExclusiveItems display 
    struct ExclusiveItems {
        uint CompanyId;
        uint marketId;
        bool services;
        string description;
        string companyName;
        address companyAddress;
        uint pointsAward;
    }

    //deciding for the exchange of poits 
    

    constructor() {
        owner = msg.sender;
    }

    //BUSINESS ASPECT 
    //registers customer also should create a stripe id, and should only be called once
    function registerCompany(string memory _name, string memory _contact, string memory _stripeID)
        public
    {
        require(allNames[_name] == 0);
        require(allAddress[msg.sender] == 0);
        _totalCompanies.increment();

        Company newComp = new Company(
            _name,
            _totalCompanies.current(),
            _contact,
            owner, 
            _stripeID,
            this
        );
        allNames[_name] = _totalCompanies.current();
        allAddress[msg.sender] = _totalCompanies.current();
        allCompanies[_totalCompanies.current()] = newComp;
    }
    //check is company already exists false registers, true login or automatically go in with wallet 
    function companyExists() public view returns(bool){
        return (allAddress[msg.sender]>0);
    }
    //returns the business uint if already registered 
    function searchAddress() public view returns(uint){
        return(allAddress[msg.sender]); 
    }
    
    //registers customer and create the stripe payment ID
    function registerCustomer(string memory _name, string memory _stripeID)public {
        require(customerNames[_name] == 0);
        require(customerAddress[msg.sender] == 0); 
        allCustomers[_totalCustomer.current()] = Customer(
            _totalCustomer.current(), 
            _name, 
            msg.sender,
            _stripeID
        );
    } 
    //returns customer Info
    function showCustomer(string memory who)public view returns(Customer memory){
        return allCustomers[customerNames[who]]; 
    }
    //list all the points the user has
    function listAllPoints() public view returns (CompanyView[] memory) {
        uint max = 0;
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            if (allCompanies[i].allPoints(msg.sender) > 0) {
                max++;
            }
        }
        CompanyView[] memory pointsCompanies = new CompanyView[](max);
        uint current = 0;
        for (uint i = 0; i < _totalCompanies.current(); i++) {
            if (allCompanies[i].allPoints(msg.sender) > 0) {
                pointsCompanies[current] = CompanyView(
                    allCompanies[i].owner(),
                    allCompanies[i].name(),
                    allCompanies[i].contact(),
                    allCompanies[i].id(),
                    allCompanies[i].allPoints(msg.sender)
                );
            }
        }
        return (pointsCompanies);
    }

    //list all the exclusive services or items the user is eligible to
    function listExclusive() public view returns (ExclusiveItems[] memory) {
        CompanyView[] memory companyPossible = listAllPoints();
        uint max = 0;
        for (uint i = 0; i < companyPossible.length; i++) {
            max += allCompanies[companyPossible[i].id]
                .displayPossibleBuy()
                .length;
        }
        ExclusiveItems[] memory allPossibleItems = new ExclusiveItems[](max);
        uint current = 0;
        for (uint i = 0; i < companyPossible.length; i++) {
            Company.ExclusiveItem[] memory allItems = allCompanies[
                companyPossible[i].id
            ].displayPossibleBuy();

            for (uint x = 0; x < allItems.length; x++) {
                allPossibleItems[current] = ExclusiveItems(
                    allCompanies[companyPossible[i].id].id(),
                    allItems[x].id, 
                    allItems[x].services, 
                    allItems[x].description, 
                    allCompanies[companyPossible[i].id].name(),
                    allCompanies[companyPossible[i].id].owner(),
                    allItems[x].pointsAward
                );
                current++;
            }
        }
        return allPossibleItems; 
    }
    //searching by name 
    function searchByName(string memory whichCompany)public view returns(uint){
        return(allNames[whichCompany]); 
    }

    
}
