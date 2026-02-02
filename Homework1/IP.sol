// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;


/* 
* @title: Subnet Masking
* @author: Tianchan Dong
* @notice: This contract illustrate how IP addresses are distributed and calculated
* @notice: This contract has no sanity checks! Only use numbers provided in constructor
*/ 

contract Masking{

    // Return Variables
    string public Country;
    string public ISP;
    string public Institute;
    string public Device;

    // Maps of IP interpretation
    mapping(uint => string) public Countries;
    mapping(uint => string) public ISPs;
    mapping(uint => string) public Institutions;
    mapping(uint => string) public Devices;

    constructor() {
        Countries[34] = "Botswana";
        Countries[58] = "Egypt";
        Countries[125] = "Brazil";
        Countries[148] = "USA";
        Countries[152] = "France";
        Countries[196] = "Singapore";
        ISPs[20] = "Orange";
        ISPs[47] = "Telkom";
        ISPs[139] = "Vodafone";
        Institutions[89] = "University";
        Institutions[167] = "Government";
        Institutions[236] = "HomeNet";
        Devices[13] = "iOS";
        Devices[124] = "Windows";
        Devices[87] = "Android";
        Devices[179] = "Tesla ECU";
    }

    function IP(string memory input) public {
        //Input your code here
        // receive code in bytes (input is 32 bits)
        // sectioning the received IP address and relate them to values in the previous part of the code
        // Devide it into 8 bits chunks
        uint country=0;
        uint isp=0;
        uint institutions=0;
        uint devices=0;
        bytes memory b=bytes(input);
        uint val=0;
        for (uint i=0; i<32; i++){
            val=val<<1;
            if (b[i] == bytes1("1")) {
                val += 1;
            } 
            
            if (i==7){   
                country=val;
                val=0;
            } else if (i==15) { 
                isp=val;
                val=0;
            } else if (i==23){   
                institutions=val;
                val=0;
            } else if (i==31){   
                devices=val;
                val=0;
            }
        } 
        // use the chunks or the mapping
        Country = Countries[country];
        ISP = ISPs[isp];
        Institute = Institutions[institutions];
        Device = Devices[devices];

        //return string.concat(country,isp,institute,device)
    }
}
