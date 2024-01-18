// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/*

This contract creates and manages tokens for a ginven university. It assigns roles to the addresses 
(or users) based on their position in real life (STU for students and CAR for careers). The address 
that lounches the contract will be the owner of the contract and will be assigned the role UNI, for
university.

Each address that wants to interact with this contract will need to be assigned a role by the 
university (except for the university itself) or it will otherwise have the role of NONE.

Students can spend their tokens for real life services and Careers can reward their students based
on real life achievements.

Roles are crucial and are useful for limiting the user's levle of freedom in running the code.
Roles are also used to relate the addresses and give logical bounds between the universty, the
careers and students.

*/

contract Universies is ERC20, ERC20Permit {

    // Variables
    address public owner; // contract's owner
    enum Role { NONE, STU, CAR, UNI}

    // Mappings
    mapping(address => address) public careerOfStudent;
    mapping(address => student) public studentRef; 
    mapping(address => address) public universityOfCareer;
    mapping(address => career) public careerRef;
    mapping(address => Role) public ownRole;

    // Modifiers
    modifier onlyUNI {
        require(ownRole[msg.sender] == Role.UNI, "Only universities can use this function");
        _;
    }
    modifier onlyCAR {
        require(ownRole[msg.sender] == Role.CAR, "Only careers can use this function");
        _;
    }
    modifier onlySTU {
        require(ownRole[msg.sender] == Role.STU, "Only students can use this function");
        _;
    }

    // Events
    event UniTransfer(address indexed to, uint256 amount);
    event Reward(address indexed from, address indexed to, uint256 amount);
    event Spend(address indexed from, address indexed to, uint256 amount);
    event Graduate(address indexed from, address indexed to, uint256 amount);
    event StudentRemoved(address indexed student, address indexed career);
    event CareerRemoved(address indexed from, address indexed to, uint256 amount);

    // Constructor
    constructor(uint256 initialSupply) ERC20("Universies", "UVS") ERC20Permit("Universies") {
        owner = msg.sender;
        ownRole[owner] = Role.UNI;
        _mint(msg.sender, initialSupply);
    }

    // Structs
    struct student { // Role STU is related only via the reference. the struct doesn't need a role because it is only used for STU addresses
        string name;
        string surnames;

        /* A given address with role STU will be tied to the following values:

            - The address number itself
            - A mapping to a struct with name/surnames
            - A mapping to the career belonging to
            - A mapping to its assigned role

        */
    }
    struct career { // Role STU is related only via the reference. the struct doesn't need a role because it is only used for STU addresses
        string name;
        string code;

        /* A given address with role CAR will be tied to the following values:

            - The address number itself
            - A mapping to a struct with name/code
            - A mapping to the university belonging to
            - A mapping to its assigned role

        */
    }

//////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                              //
//                                                                                              //
//                                          Functions                                           //
//                                                                                              //
//                                                                                              //
//////////////////////////////////////////////////////////////////////////////////////////////////

// Setters ///////////////////////////////////////////////////////////////////////////////////////

    // Student
    function setStudent(address user, string memory name, string memory surnames, address ownCareer) external onlyUNI{
        require(ownRole[user] == Role.NONE, "This address is already in the system");
        require(ownRole[ownCareer] == Role.CAR, "Invalid Career");

        student memory stu = student ({

            name: name,
            surnames: surnames

        });

        studentRef[user] = stu;
        careerOfStudent[user] = ownCareer;
        ownRole[user] = Role.STU;
    }

    // Career
    function setCareer(address user, string memory name, string memory code, address ownUniversity) external onlyUNI{
        require(ownRole[user] == Role.NONE, "This address is already in the system");
        require(ownRole[ownUniversity] == Role.UNI, "This address is not a university");

        career memory car = career ({

            name: name,
            code: code

        });

        careerRef[user] = car;
        universityOfCareer[user] = ownUniversity;
        ownRole[user] = Role.CAR;
    }

// Transfers /////////////////////////////////////////////////////////////////////////////////////

    // UNI can use this function to transfer anybody
    function uniTransfer(address to, uint amount) external onlyUNI {
        _transfer(msg.sender, to, amount);

        emit UniTransfer(to, amount);
    }

    // CAR addresses can use this function to reward STU addresses
    function reward(address to, uint amount) external onlyCAR {
        require(ownRole[to] == Role.STU && careerOfStudent[to] == msg.sender, "Invalid receiver");
        _transfer(msg.sender, to, amount);

        emit Reward(msg.sender, to, amount);
    }

    // STU addresses can use this function to pay a given service, which translates in transferring tokens to a UNI or a CAR address
    function spend(address to, uint amount) external onlySTU {
        require(ownRole[to] == Role.UNI || (ownRole[to] == Role.CAR && careerOfStudent[msg.sender] == to), "Invalid receiver");
        _transfer(msg.sender, to, amount);

        emit Spend(msg.sender, to, amount);
    }

// Removers //////////////////////////////////////////////////////////////////////////////////////

    // Reverts the mappings (this address will have no student struct, no career mapping and a role of NONE) for a student
    function RemoveStu(address user, bool graduated) external onlyUNI {
        require(ownRole[user] == Role.STU, "Student doesn't exist");
        if(balanceOf(user) > 0) {

            if (graduated == true){

                uint returnBalance = (balanceOf(user)*20)/100; // A graduated srudent cas to pay a 20% of his balance to the carees noted in the list of the struct
                _transfer(user, careerOfStudent[user], returnBalance);
                emit Graduate(user, careerOfStudent[user], returnBalance);

            }

        }

        emit StudentRemoved(user, careerOfStudent[user]);
        delete studentRef[user];
        delete careerOfStudent[user];
        ownRole[user] = Role.NONE;
    }

    // Reverts the mappings (this address will have no career struct, no university mapping and a role of NONE) for a career
    function RemoveCar(address user) external onlyUNI {
        require(ownRole[user] == Role.CAR, "Career doesn't exist");

        if(balanceOf(user) > 0) {

            uint oldBalance = balanceOf(user);
            _transfer(user, msg.sender, balanceOf(user));
            emit CareerRemoved(user, msg.sender, oldBalance);

        }

        
        delete careerRef[user];
        delete universityOfCareer[user];
        ownRole[user] = Role.NONE;
    }

}

