// // SPDX-License-Identifier: GPL-3.0
// import "@openzeppelin/contracts/utils/Counters.sol";
// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

// pragma solidity ^0.8.9;

// contract Loyalty is ERC1155{
//     using Counters for Counters.Counter;

//     //CUSTOMER SHIT 
//     Counters.Counter private _personCount; 
//     mapping(uint => Customer)personId; 
//     mapping(string => Customer)CustomerName; 
//     mapping(address => Customer)CustomerAddress;
//     struct Customer{
//         string name; 
//         address personAddress;
//         string description; 
//         uint id; 

//     }


//     //TOKEN INFO SHIT 
//     Counters.Counter private _tokenCount;
//     mapping(uint => TokenEarn) allTokens;
//     struct TokenEarn {
//         uint tokenID;
//         string name;
//         string companyName;
//         address companyAddress;
//         string URI;
//         bool valid;
//         uint pricePoints;
//         uint royalty;
//     }

//     //constructor 
//      constructor() ERC1155("https://nftstorage.link/ipfs/${id}") {
//         uint currentToken = _tokenCount.current();
//         TokenEarn memory firstToken = TokenEarn(
//             currentToken,
//             "Good Tokens",
//             "Owner Company",
//             msg.sender,
//             "URI here",
//             true,
//             0,
//             10
//         );
//         _mint(msg.sender, currentToken, 20, "");
//         allTokens[currentToken] = firstToken;
//         _tokenCount.increment();
//     }


//     //Customer Shit 
//    function registerCustomer(string memory _name, string memory aboutMyself) public {
//         require(CustomerName[_name].id == 0, "Name already taken");
//         //require so that not one eth address can register multiple times
//         require(
//             CustomerAddress[msg.sender].id == 0,
//             "already registered with address, please log in"
//         );
//         Customer memory newCus = Customer(_name,msg.sender,)
//         CustomerName[_name] 
        
//     }

//     //check if customer exists 
//     function customerExists()public view returns(bool) {
//         bool registered = false; 
//         if( CustomerAddress[msg.sender].id > 0){
//             registered = true; 
//         }
//         return registered; 
//     }
// }