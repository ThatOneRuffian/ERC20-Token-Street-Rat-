pragma solidity ^0.4.18;

contract SRat{
     //add token name, supply, address mappings.
    string constant public name = "Street Rat Coin"; //street rat coin
    
    string constant public symbol = "SRat"; 
   
    uint8 constant public decimals = 2; //$0.00
    
    uint256 constant public initialSupply = 2300000000000000; // 2.3 Trillion.
    
    uint256 constant public maxSupply = 10000000000000000;
    
    address public federalReserveWallet; // I mean street rat coin...

    uint256 public totalMoneySupply = 0; //keeps track of total money supply.

    mapping (address => uint256) public balanceOf; //create a map addresses x value
   
    mapping (address => bool) public banStatus;  //Maps address to their ban status. 1 == Banned || 0 == not banned.
    
    mapping (address => bool) public adminStatus; //Map admins or ppl allowed to print/widthdrawl from main fund.
    
    
    function SRat() public{ //Coin constructor
        
        federalReserveWallet = msg.sender; //owner/holder of main funds is contract deployer.

        adminStatus[federalReserveWallet] = true; //Add contract wallet to list of admins.

        totalMoneySupply = initialSupply; // Total current money in circulation.
       
        balanceOf[federalReserveWallet] = initialSupply; //Initialize Central bank starting balance minus payoffs.
    }
    
    event writeLog(
        string msg
        );

        
    modifier isAdmin {   // admin check.
        require(adminStatus[msg.sender]);
        _;
    }
    
    
    modifier isDeployer{
        require(msg.sender == federalReserveWallet);
        _;
    }
    

    function transfer(address to, uint256 amount ) public{ //Transfer street rat from one person to another.
        
        require( (balanceOf[msg.sender] >= amount)); // greater than amount they control.
        require( !banStatus[msg.sender] && !banStatus[to]); //If 1 banned member is envolved transaction is cancled.
        
        balanceOf[msg.sender] -= amount;//update balances
        balanceOf[to] += amount;
        writeLog("Token TX complete.");
       
    }
    
    
    function withdrawalToken(address recipient, uint256 amount) isAdmin public{ //Withdrawl funds from main wallet. Requires admin rights.
       
        require(recipient != federalReserveWallet); //Fed -> Fed makes no sense. Save gas.
        require(balanceOf[federalReserveWallet] >= amount);
        
        balanceOf[federalReserveWallet] -= amount; //Remove funds from main account fed holder.
        balanceOf[recipient] += amount;            //Add to funds recipint.
        writeLog("Token withdrawal complete.");
       
    }
    
    
    function widthdrawlmETH(address recipient, uint256 amount) isDeployer public returns(bool){ // widthdrawl ether from main contract in millieth.
       
        require(amount <= this.balance);
        
        uint64 toMilli = 10**15; //coefficient to convert wei to millieth
        
        amount *= toMilli; //convert wei to millieth.

        recipient.transfer(amount);
        writeLog("ETH widthdrawal TX generated.");
        
        return true;
    }
    
    
    function  printMoreTokens (uint256 mintAmount) isAdmin public{ //print a supplied amount of street rat.
        
        require(mintAmount > 0);
        require(totalMoneySupply != maxSupply);
        
        if( (mintAmount + totalMoneySupply) >= maxSupply){  //Cap 100000000000000 or 100 trillion. If overprint set to max.
           
            totalMoneySupply = maxSupply;
            balanceOf[federalReserveWallet] = maxSupply;  //Add minted amount to contract wallet
            writeLog("Max token supply reached.");
        }
       
        else{ //print more tokens
        
            totalMoneySupply += mintAmount;
            balanceOf[federalReserveWallet] += mintAmount;  //Add minted amount to contract wallet
            writeLog("Token supply increased.");
        }
    }
    
    
    function addCentralBanker(address newBanker) isDeployer public{ //Add address as central banker. better method?
       
        adminStatus[newBanker] = true;
        writeLog("Central banker added.");
    }
    
    
    function removeCentralBanker(address banker) isDeployer public{  //Remove address as central banker.
        
        require(banker != federalReserveWallet);//Make sure contract wallet can't be removed from admin.
        
        adminStatus[banker] = false; //Remove Central Banker privledges.
        writeLog("Central banker removed.");
    }
    
    
    function lockAccount(address toBan) isAdmin public{ //Stops locked account from sending/receiving any street rat coin.
      
        writeLog("Account Locked.");
        banStatus[toBan] = true;   //Activate ban
    }
    
    
    function unlockAccount(address unBan) isAdmin public{ //unlocks account so the street rats can flow again.
        
        banStatus[unBan] = false; //Remove ban
        writeLog("Account unlocked.");
    }
    
   
    function voidContract() isDeployer public { //self-destruct function. It's been good....shut it down.
        
        writeLog("Contract destroyed.");
        selfdestruct(federalReserveWallet); //destroy contract and return eth funds to provided addr.
    }
           
           
     function() public payable{ //Take eth donations.

        writeLog("Payment Received. Thank you."); 
    }
    
}