import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.9;



contract Company {
    //payment will be made through stripe
    address public companyAdd;
    string public stripeId;
    string public name;
    struct products {
        string name;
        uint levelRequired;
        string priceId;
        uint price;
        uint points;
    }

    constructor(string memory _stripeId, string memory _name) {
        companyAdd = msg.sender;
        stripeId = _stripeId;
        name = _name;
    }

    
}

contract Customer {
    string public name;
    address public ownerAdd;
    //address of the company and how much points they have
    mapping(address => uint)  companyPoints;

    constructor(string memory _name) {
        name = _name;
        ownerAdd = msg.sender;
    }

    function addPoints(address toCompany, uint amount)public {
        companyPoints[toCompany] += amount; 
    }
}

contract Loyalty is ERC721URIStorage {
    constructor() ERC721("Loyalty", "Loyal") {}

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(address => Company) companyAdd;
    mapping(address => uint) existCom;
    mapping(string => address)companyName; 

    mapping(address => Customer) public allNames;
    mapping(address => uint) existCus;

    //general information 
    //lookup company info by name and return address 
    function getCompanyAddress(string memory compAdd)public view returns(address){
        return companyName[compAdd]; 
    }

    //giving points by vouchers
    //all vouchers by the company
    //first by company, and then the list of vouchers
    mapping(address => mapping(string => Voucher)) public allVouchers;
    struct Voucher {
        uint amount;
        string name;
    }

    //must be called by the address of the company owner
    function createVoucher(string memory _voucherName, uint _amount) public {
        require(allVouchers[msg.sender][_voucherName].amount == 0);
        allVouchers[msg.sender][_voucherName] = Voucher(_amount, _voucherName);
    }

    //called by the user 
    function redeemVoucher(string memory _code,address company )public {
        Customer thisCus = allNames[msg.sender];
        require(allVouchers[company][_code].amount > 0);
        thisCus.addPoints(company, allVouchers[company][_code].amount);
        allVouchers[company][_code].amount = 0;
    }


    //setting up company
    //first set up with stripe first tho
    //then this would be invoked last
    //register using company's address
    function createCompany(string memory _stripeId, string memory _name)
        public
    {
        require(existCom[msg.sender] == 0);
         companyName[_name] = msg.sender;
        existCom[msg.sender] = 1;
        companyAdd[msg.sender] = new Company(_stripeId, _name);
    }

    //register customer to blockchain only
    function registerCustomer(string memory _name) public {
        require(existCus[msg.sender] == 0);
        existCus[msg.sender] = 1;
        allNames[msg.sender] = new Customer(_name);
    }

    
}
