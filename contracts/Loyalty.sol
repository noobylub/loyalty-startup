// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/utils/Counters.sol";

pragma solidity ^0.8.9;

//we should have function that returns details of themselves
contract Loyalty {
    using Counters for Counters.Counter;
    Counters.Counter private _totalCompanies;

    //conversion so that it is easier to identify people
    mapping(string => bool) idExist;
    mapping(address => bool) registeredID;
    mapping(string => address) personId;

    mapping(address => mapping(string => uint)) allPoints;

    Counters.Counter private _programCount;
    mapping(string => mapping(uint => mapping(address => bool))) programEntered;
    mapping(uint => PointProgram) allPrograms;
    struct PointProgram {
        uint numberId;
        address owner;
        string ownerName;
        uint cost;
        string ipfsDescription;
        bool valid;
        string programName;
    }

    mapping(string => mapping(string => uint)) catchphraseProgram;
    mapping(string => string[]) phraseExist;
    mapping(string => mapping(string => uint)) phraseExistIndex;

    struct Company {
        address owner;
        string name;
        string contact;
        uint totalPurchase;
        uint discount;
        uint id;
    }

    //sometimes identify with address with the msg.sender
    //sometimes with string as it is easier
    //we also need to check if they exist or not .
    mapping(address => string) idToNameCompany;
    mapping(string => Company) allCompanies;
    mapping(string => bool) existNot;
    mapping(address => bool) addressExistsCompany;
    mapping(uint => string) companiesId;

    function registerCustomer(string memory _name) public {
        require(idExist[_name] == false, "Name already taken");
        //require so that not one eth address can register multiple times
        require(
            registeredID[msg.sender] == false,
            "already registered with id"
        );
        registeredID[msg.sender] = true;
        idExist[_name] = true;
        personId[_name] = msg.sender;
    }

    //registers company
    //registers company
    function registerCompany(string memory _name, string memory _contact)
        public
    {
        require(existNot[_name] == false);
        require(addressExistsCompany[msg.sender] == false);

        Company memory newComp;
        newComp.owner = msg.sender;
        newComp.name = _name;
        newComp.contact = _contact;
        newComp.totalPurchase = 0;

        newComp.id = _totalCompanies.current();
        _totalCompanies.increment();
        addressExistsCompany[msg.sender] = true;
        idToNameCompany[msg.sender] = _name;
        allCompanies[_name] = newComp;
        existNot[_name] = true;
        companiesId[newComp.id] = _name;
    }

    //giving points
    //the only people who can give are the owner
    //my point here is for the point of sale after the buyer buys the products
    function givingPoints(uint amount, string memory personTo) public {
        string memory companyName = idToNameCompany[msg.sender];
        require(existNot[companyName] == true);
        require(allCompanies[companyName].owner == msg.sender);

        address personAddress = personId[personTo];
        allPoints[personAddress][companyName] += amount;
    }

    // //Company creating a catchphrase for handing Points .
    function createCatchphrase(string memory catchphrase, uint _pointAmount)
        public
    {
        string memory whichCompany = idToNameCompany[msg.sender];
        require(existNot[whichCompany] == true);
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
    function gettingCatchphrasePoint(
        string memory programName,
        string memory whichCompany
    ) public {
        require(existNot[whichCompany] == true);
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
            keccak256(abi.encodePacked((idToNameCompany[msg.sender]))) ==
                keccak256(abi.encodePacked((whichCompany))),
            "You must be the owner of the Company"
        );
        return phraseExist[whichCompany];
    }

    //program shit
    //program to send points
    function createProgram(
        string memory _programName,
        string memory _description,
        uint _cost
    ) public {
        require(
            addressExistsCompany[msg.sender] == true,
            "Company must be registered"
        );
        string memory whichCompany = idToNameCompany[msg.sender];
        uint currentNumber = _programCount.current();
        PointProgram memory newProgram = PointProgram(
            currentNumber,
            msg.sender,
            whichCompany,
            _cost,
            _description,
            true,
            _programName
        );
        allPrograms[currentNumber] = newProgram;
        _programCount.increment();
    }

    function enterProgram(uint _idProgram) public {
        require(
            _idProgram < _programCount.current(),
            "Impossible, program does not exist"
        );
        string memory whichCompany = allPrograms[_idProgram].ownerName;
        programEntered[whichCompany][_idProgram][msg.sender] = true;
    }

    //only the program owner can turn off program
    function turnOffProgram(uint idProgram) public {
        require(allPrograms[idProgram].owner == msg.sender);
        allPrograms[idProgram].valid = false;
    }

    function turnOnProgram(uint idProgram) public {
        require(allPrograms[idProgram].owner == msg.sender);
        allPrograms[idProgram].valid = true;
    }

    function deleteProgram(uint idDelete) public {
        if (idDelete == _programCount.current() - 1) {
            _programCount.decrement();
        } else {
            allPrograms[idDelete] = allPrograms[_programCount.current()-1];
            _programCount.decrement();
        }
    }

    //the only one who can redeem program are the owners of the store
    function redeemProgram(uint _idProgram, string memory personRedeeming)
        public
    {
        address person = personId[personRedeeming];
        PointProgram memory redeemThis = allPrograms[_idProgram];
        require(
            redeemThis.owner == msg.sender,
            "You need to be the owner of the program"
        );
        require(
            programEntered[redeemThis.ownerName][_idProgram][person] == true,
            "Person does not have this program"
        );
        programEntered[redeemThis.ownerName][_idProgram][person] = false;
    }

    //list all programs by the company
    function listAllPrograms() public view returns (PointProgram[] memory) {
        string memory companyAdd = idToNameCompany[msg.sender];
        require(existNot[companyAdd] == true);
        uint max = 0;
        for (uint i = 0; i < _programCount.current(); i++) {
            if (allPrograms[i].owner == msg.sender) {
                max++;
            }
        }
        PointProgram[] memory listingAllProgram = new PointProgram[](max);
        uint count = 0;
        for (uint i = 0; i < _programCount.current(); i++) {
            if (allPrograms[i].owner == msg.sender) {
                listingAllProgram[count] = allPrograms[i];
                count++;
            }
        }
        return listingAllProgram;
    }

    //called by the users to list all programs for a company
    function listAvaiablePrograms(string memory whichCompany)
        public
        view
        returns (PointProgram[] memory)
    {
        uint max = 0;
        for (uint i = 0; i < _programCount.current(); i++) {
            if (
                keccak256(bytes(allPrograms[i].ownerName)) ==
                keccak256(bytes(whichCompany)) &&
                allPrograms[i].valid == true
            ) {
                max++;
            }
        }
        PointProgram[] memory validPrograms = new PointProgram[](max);
        uint count = 0;
        for (uint i = 0; i < _programCount.current(); i++) {
            if (
                keccak256(bytes(allPrograms[i].ownerName)) ==
                keccak256(bytes(whichCompany)) &&
                allPrograms[i].valid == true
            ) {
                validPrograms[count] = allPrograms[i];
                count++;
            }
        }
        return validPrograms;
    }

    //spending points
    //the customer request
    function spendingPoints(uint pCost, string memory whichCompany)
        public
        returns (bool)
    {
        require(existNot[whichCompany] == true);
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
        for (uint i = 0; i < _totalCompanies.current(); i++) {
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
