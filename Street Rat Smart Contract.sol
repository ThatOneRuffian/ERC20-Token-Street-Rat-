pragma solidity ^0.4.18;

contract SRat{
     //add token name, supply, address mappings.
    string constant public name = "Street Rat Coin"; //street rat coin
    
    string constant public symbol = "SRat"; 
   
    uint8 constant public decimals = 2; //$0.00
    
    uint256 constant public initialSupply = 23000000000000; // 2.3 Trillion.
    
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
    
    event testEvent(
        address indexed testAddr,
        string value
        
    );
    
    event paymentReceived(
        address indexed paymentAddr,
        uint256 indexed payAmount,
        string msg
        );
    
    modifier isAdmin {   //Modifier fuction for modular admin check.
        require(adminStatus[msg.sender]);
        _;
    }
    
    
    function transfer(address to, uint256 amount ) public returns(bool) { //Transfer street rat from one person to another.
        
        require( (balanceOf[msg.sender] >= amount)); // greater than amount they control.
        require( !banStatus[msg.sender] && !banStatus[to]); //If 1 banned member is envolved banned transactions of FEDCoin.
        
        balanceOf[msg.sender] -= amount;//update balances
        balanceOf[to] += amount;
        
        return true;
    }
    
    
    function withdrawal(address recipient, uint256 amount) isAdmin public returns (bool){ //Withdrawl funds from main wallet. Requires admin rights.
       
        require(recipient != federalReserveWallet); //Fed -> Fed makes no sense. Save gas.
        require(balanceOf[federalReserveWallet] >= amount);
        
        balanceOf[federalReserveWallet] -= amount; //Remove funds from main account fed holder.
        balanceOf[recipient] += amount;            //Add to funds recipint.
        
        return true;//add event?
    }
    
    
    function  printMoreFED (uint256 mintAmount) isAdmin public returns(bool) { //print a supplied amount of street rat.
        
        require((mintAmount + totalMoneySupply) <= 100000000000000);  //Cap 100000000000000 or 100 trillion.
        totalMoneySupply += mintAmount;
        balanceOf[federalReserveWallet] += mintAmount;  //Add minted amount to contract wallet
        //add event?
        return true;
    }
    
    
    function addCentralBanker(address newBanker) isAdmin public returns(bool){ //Add address as central banker. better method?
       
        adminStatus[newBanker] = true;
        return true;
       
        //add event?
    }
    
    
    function removeCentralBanker(address banker) isAdmin public returns(bool){  //Remove address as central banker.
        
        require(federalReserveWallet != msg.sender);//Make sure contract wallet can't be removed from admin.
        
        adminStatus[banker] = false; //Remove Central Banker privledges.
        return true;
        //add event?
    }
    
    
    function lockAccount(address toBan) isAdmin public returns(bool){ //Stops locked account from sending/receiving any street rat coin.

        banStatus[toBan] = true;   //Activate ban
        return true;
    }
    
    
    function unlockAccount(address unBan) isAdmin public returns(bool){ //unlocks account so the street rats can flow again.
        
        banStatus[unBan] = false; //Remove ban
        return true;
    }
    
   
    function voidContract() isAdmin public { //self-destruct function. It's been good....shut it down.
        
        require(msg.sender == federalReserveWallet);
        testEvent(msg.sender, "Contract destroyed.");
        selfdestruct(federalReserveWallet); 
        
    }
           
     function() public payable{ 
         
         require(msg.value > 0);
         
         uint256 payAmount = msg.value; //Gwei
         payAmount *= 100000; // ETH
         payAmount *= 500; // 1 ETH == 500 tokens
         
         withdrawal(msg.sender, payAmount); //withdrawal tokens and send to supplier of eth
         paymentReceived(msg.sender, payAmount, "Payment Received. Thank you.");
         payAmount = 0; //reset payAmount
    }
    
}