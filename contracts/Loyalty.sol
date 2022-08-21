// SPDX-License-Identifier: GPL-3.0
import "@openzeppelin/contracts/utils/Counters.sol";


pragma solidity ^0.8.9;
 //we should have function that returns details of themselves
contract Loyalty{

    using Counters for Counters.Counter;
    Counters.Counter private _totalCompanies; 
    //setting up
    //keeps track of all the points
    //each person has a list of companies
    mapping(string => bool)idExist; 
    mapping(address => bool)registeredID; 
    mapping(string => address)personId; 
    

    mapping(address => mapping(string => uint))allPoints;
     
    //to keep track of which companies the user has points in
    //we use index to keep track 
    //and boolean to see if it actually exist or not in the registry 
    
    // mapping(address => mapping(string => uint))personHasIndex;
    // mapping(address => string[])allCompaniesPerson;
   
    //from company name, to program name to individuals who are in it checked by boolean
    mapping(string => mapping(string => mapping(address => bool)))programEntered; 
    mapping(string => mapping(string => bool))programValid; 
    //program description using ipfs and web3storage
    mapping(string => mapping(string => PointProgram))programDescription; 
    
    //to keep track programs
    mapping(string => string[])allPrograms; 
    mapping(string => mapping(string => uint))allProgramsIndex; 
    
    
    struct PointProgram{
        address owner; 
        uint cost; 
        string ipfsDescription;
        bool valid; 
    }



    struct programCode{
        uint maxRedeem;
        uint pointAmount;
       
    }
    //code can only be redeemed
    //exist or not for above also we have the array and index mapping to keep track 
    mapping(string => mapping(string => uint))catchphraseProgram; 
    mapping(string => string[])phraseExist;
    mapping(string => mapping(string => uint))phraseExistIndex; 

    
   
  
   
 
    struct Company{
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
    mapping(address => string)idToNameCompany; 
    mapping(string => Company)allCompanies;
    mapping(string => bool)existNot;
    mapping(address => bool)addressExistsCompany; 
    mapping(uint => string)companiesId; 

    function registerCustomer(string memory _name)public  {
        require(idExist[_name] == false, "Name already taken"); 
        //require so that not one eth address can register multiple times 
        require(registeredID[msg.sender] == false, "already registered with id"); 
        registeredID[msg.sender] = true; 
        idExist[_name] = true; 
       personId[_name] = msg.sender; 
    }
 
    //registers company
     //registers company
    function registerCompany(string memory _name, string memory _contact)public {
        require(existNot[_name] == false);
        require(addressExistsCompany[msg.sender] ==  false);
       

        Company memory newComp ;
        newComp.owner = msg.sender ;
        newComp.name = _name ;
        newComp.contact = _contact;
        newComp.totalPurchase = 0;
        //to start with zero
        newComp.id = _totalCompanies.current(); 
         _totalCompanies.increment(); 


        addressExistsCompany[msg.sender] = true; 
        idToNameCompany[msg.sender] = _name; 
        allCompanies[_name] = newComp ;
        existNot[_name] = true;
        companiesId[newComp.id] = _name; 
    }
 
    
    
 
    //giving points
    //the only people who can give are the owner
    //my point here is for the point of sale after the buyer buys the products 
    function givingPoints(uint amount, string memory personTo)public {
         string memory companyName = idToNameCompany[msg.sender]; 
        require (existNot[companyName] == true);
        require(allCompanies[companyName].owner == msg.sender);
       
        address personAddress = personId[personTo]  ;
        allPoints[personAddress][companyName] += amount;
        // if(allPoints[personAddress][companyName] == 0){
        //     allCompaniesPerson[msg.sender].push(companyName);
        //     uint end = allCompaniesPerson[msg.sender].length -1;
        //     personHasIndex[msg.sender][companyName] = end;
           
        // }
    }
    // //Company creating a program.
    function createCatchphrase(string memory catchphrase, uint _pointAmount)public {
        string memory whichCompany = idToNameCompany[msg.sender];
        require (existNot[whichCompany] == true);
        require(allCompanies[whichCompany].owner == msg.sender);
        //designs a secret catchphrase that user would hvae to find out.
        catchphraseProgram[whichCompany][catchphrase] = _pointAmount;
        phraseExist[whichCompany].push(catchphrase);
        phraseExistIndex[whichCompany][catchphrase] = phraseExist[whichCompany].length - 1; 
    }
 
    //redeeming program will also lead to deletion of the specific catchphrase 
    function gettingCatchphrasePoint(string memory programName, string memory whichCompany)public{
        require(existNot[whichCompany] == true);
        require(catchphraseProgram[whichCompany][programName]> 0);
        allPoints[msg.sender][whichCompany] += catchphraseProgram[whichCompany][programName]; 
        catchphraseProgram[whichCompany][programName] = 0; 

        uint indexRedeemed = phraseExistIndex[whichCompany][programName];
        if(indexRedeemed == phraseExist[whichCompany].length){
             phraseExist[whichCompany].pop();
        }
        else{
            phraseExist[whichCompany][indexRedeemed] = phraseExist[whichCompany][phraseExist[whichCompany].length-1]; 
            phraseExistIndex[whichCompany][phraseExist[whichCompany][indexRedeemed]] = indexRedeemed; 
            phraseExist[whichCompany].pop();

        }


       

 
    }

    //list of all the program catchprases 
    function listCatchphraseProgram(string memory whichCompany)public view returns(string[] memory){
        return phraseExist[whichCompany]; 
    }
    //program to send points 
    function createProgram(string memory _programName, string memory _description, uint _cost)public {
        string memory whichCompany = idToNameCompany[msg.sender]; 
        require(allCompanies[whichCompany].owner == msg.sender); 
        require(programValid[whichCompany][_programName] == false ); 
        programValid[whichCompany][_programName] = true;
        PointProgram memory newProgram = PointProgram(msg.sender,_cost, _description, true);
        programDescription[whichCompany][ _programName] = newProgram; 
        allPrograms[whichCompany].push(_programName);
        uint index = allPrograms[whichCompany].length -1; 
        allProgramsIndex[whichCompany][_programName] = index; 
        
    }

    function enterProgram (string memory _programName, string memory whichCompany)public{
        require(programDescription[whichCompany][_programName].cost >= allPoints[msg.sender][whichCompany] ); 
        require(programDescription[whichCompany][_programName].valid == true, "Invalid to enter right now");
        uint cost = programDescription[whichCompany][_programName].cost; 
        allPoints[msg.sender][whichCompany] -= cost; 
        programEntered[whichCompany][_programName][msg.sender] = true; 

    }
    //only the program owner can turn off program 
    function turnOffProgram(string memory _programName)public {
        string memory whichCompany = idToNameCompany[msg.sender]; 
        require(programDescription[whichCompany][_programName].owner == msg.sender); 
        programDescription[whichCompany][_programName].valid = false; 

        uint index = allProgramsIndex[whichCompany][_programName];
        if(index == allPrograms[whichCompany].length-1){
            allPrograms[whichCompany].pop();
        } 
        else{
            allPrograms[whichCompany][index] = allPrograms[whichCompany][allPrograms[whichCompany].length-1]; 
            allProgramsIndex[whichCompany][allPrograms[whichCompany][index]] = index; 
            allPrograms[whichCompany].pop(); 
        }
        

    }

    //the only one who can redeem program are the owners of the store 
    function redeemProgram(string memory _programName,string memory whichCompany, string memory personRedeeming )public {
        address idPerson = personId[personRedeeming]; 
        require(programEntered[whichCompany][_programName][idPerson] == true, "Person does not have the program");
        programEntered[whichCompany][_programName][idPerson] = false; 
    }
    //called by the users to list all programs for a company
    function listAllPrograms(string memory whichCompany )public view returns(PointProgram[] memory){
        string[] memory programsAvaiable = allPrograms[whichCompany]; 
        PointProgram[] memory pointPrograms = new PointProgram[](programsAvaiable.length);
        for(uint i =0; i<programsAvaiable.length; i++){
            pointPrograms[i] =  programDescription[whichCompany][programsAvaiable[i]];
        }
        return pointPrograms;
    }   

    
   
 
   
    //spending points
    //the customer request  
    function spendingPoints (uint pCost, string memory whichCompany )public returns(bool) {
        require(existNot[whichCompany] == true);
        require(pCost <= allPoints[msg.sender][whichCompany], "Needs more points");
        allPoints[msg.sender][whichCompany] -= pCost;
        // if(allPoints[msg.sender][whichCompany] == 0){
            
        //     uint index = personHasIndex[msg.sender][whichCompany];
        //     if(index == allCompaniesPerson[msg.sender].length -1){
        //         allCompaniesPerson[msg.sender].pop();
        //     }
        //     else{
        //         allCompaniesPerson[msg.sender][index] = allCompaniesPerson[msg.sender][allCompaniesPerson[msg.sender].length -1];
        //         allCompaniesPerson[msg.sender].pop();
        //         personHasIndex[msg.sender][allCompaniesPerson[msg.sender][index]] = index;
        //     }
             
        // }
        return true;
    }
 
 
    //getting points for each company 
    function gettingDetails(string memory whichCompany)public view returns(uint){
        return allPoints[msg.sender][whichCompany];
    }
 
    // function personPPT()public view returns( string[] memory){
    //     return allCompaniesPerson[msg.sender];
    // }


    //remember this when reading multiple values https://blockheroes.dev/js-read-multiple-returned-values-solidity/
    function gettingPointsCompanies()public view returns(string[] memory, uint[] memory){
        uint max = 0;
        for(uint i=0; i<_totalCompanies.current();i++){
             string memory whichCompany = companiesId[i]; 
            if(allPoints[msg.sender][whichCompany]> 0){
                max++; 
            }
        }
        string[] memory personHasPoints = new string[](max) ; 
        uint[] memory personAmountPoints= new uint[](max); 
        uint count = 0; 
        for(uint i =0; i<_totalCompanies.current(); i++){
            //go through each company and if person has point more than zero here, add to the string 
            string memory whichCompany = companiesId[i]; 
            if(allPoints[msg.sender][whichCompany] > 0){
                personHasPoints[count] = whichCompany; 
                personAmountPoints[count] = allPoints[msg.sender][whichCompany]; 
                count++;
            }
        }
        return (personHasPoints, personAmountPoints); 
    }

   
 
   
 
 
 
}
 

