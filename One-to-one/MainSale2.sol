pragma solidity ^0.4.20;

import 'browser/Ownable.sol';
import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';


contract MainSale2 is Sale {
  
    function MainSale2(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
        stagenum=2;
        saleTokenLimit = 15000000 * 1 ether;
        
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        bounty = 0x583031D1113aD414F02576BD6afaBfb302140225;
        reserved= 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        
       
      
        restrictedPercent = 10;
        reservedPercent=5;
        bountyPercent=5;
    
        rate = 1000;
        start = 1520284311;
        period = 28;
        
    }

    function Max2BuyTokens() public view returns (uint max2buy)
    {
       uint max = myBalance().mul(100).div(restrictedPercent.add(bountyPercent).add(reservedPercent).add(100)); //проверить!!
       max2buy=max.div(rate).mul(rate); //обнуляем остаток
    }
    
    bool BlockTimeIsSet=false;

    function buyTokens() public canBuy  payable
    {
        if (!BlockTimeIsSet)
        {
          token.AddBlockTime(restricted, 1 years);
            token.AddBlockTime(reserved, 1 years);
            BlockTimeIsSet=true;
        }
        uint tokens = rate.mul(msg.value);
        uint restrictedTokens = tokens.mul(restrictedPercent).div(100);
        uint bountyTokens = tokens.mul(bountyPercent).div(100);
        uint reservedTokens = tokens.mul(reservedPercent).div(100);
        uint totaltokens=tokens.add(restrictedTokens).add(bountyTokens).add(reservedTokens);
        require( totaltokens <= myBalance());
      
      
        InvestmentsStorage ist = InvestmentsStorage(selector.investmentsStorage());
        ist.AddWei.value(msg.value)(msg.sender, stagenum);
        
        token.transferFromAgent(restricted, restrictedTokens);
        token.transferFromAgent(bounty, bountyTokens);
        token.transferFromAgent(reserved, reservedTokens);
        token.transferFromAgent(msg.sender, tokens); 
       
    }
    
    function finalizeSale() public onlyOwner returns (bool)
    {
        
        if (now > saleEnd() || Max2SpendWei()<1) //меньше rate за 1 wei не купишь, такие значения могут оставаться после расчета процентов, поэтому их просто сжигаем  (напоминаю 1 токен на счету - это balances[address]==1*10^18)
        {
            token.burnAllOfAgent();
            token.setEndSales();
            return true;
        }
        
      
      
        return false;
       
    }
}