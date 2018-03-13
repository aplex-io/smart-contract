pragma solidity ^0.4.20;

import 'browser/Ownable.sol';
import 'browser/InvestmentsStorage.sol';
import 'browser/Sale.sol';

contract MainSale is Sale {
  
    function MainSale(address _versionSelectorAddress) Sale(_versionSelectorAddress) public {
    
        saleTokenLimit = 25000000 * 1 ether;
        stagenum=1;
        
        restricted = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
        bounty = 0x583031D1113aD414F02576BD6afaBfb302140225;
        reserved= 0x8070c0D731Efc7c041096a2D1B90805b6Db79dC6;
        
        
        
        restrictedPercent = 10;
        reservedPercent=5;
        bountyPercent=5;
        
        rate = 1000;
        start = 1519761460;
        period = 30;
    }

    bool BlockTimeIsSet=false;
    
    function Max2BuyTokens() public view returns (uint max2buy)
    {
        uint balance=myBalance();
        
       
        uint tpercent=0;
        
        if (now.sub(start) < 3 weeks)
        {
            tpercent=5; //если 3 неделя, то 5%
        }
        
        
        if (now.sub(start) < 2 weeks)
        {
            tpercent=10; //если 2 неделя, то 10%
        }
        
        
        if (now.sub(start) < 1 weeks)
        {
            tpercent=15; //если 1 неделя, то 15%
        }
        
        
        if (now.sub(start) < 1 days)
        {
            tpercent=20; //если 1 день, то 20%
        }
        
        uint percent=restrictedPercent.add(bountyPercent).add(reservedPercent);
        
        uint maxwei=1000 ether;
        uint maxbonused=maxwei.mul(rate).mul(tpercent.add(20)).div(100);
        uint total=maxbonused.add(maxbonused.mul(percent).div(100));
        uint lastBuyerPercent=tpercent.add(20);
        uint max;
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        maxwei=100 ether;
        maxbonused=maxwei.mul(rate).mul(tpercent.add(15)).div(100);
        total=maxbonused.add(maxbonused.mul(percent).div(100));
        lastBuyerPercent=tpercent.add(15);
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        maxwei=10 ether;
        maxbonused=maxwei.mul(rate).mul(tpercent.add(10)).div(100);
        total=maxbonused.add(maxbonused.mul(percent).div(100));
        lastBuyerPercent=tpercent.add(10);
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        maxwei=1 ether;
        maxbonused=maxwei.mul(rate).mul(tpercent.add(5)).div(100);
        total=maxbonused.add(maxbonused.mul(percent).div(100));
        lastBuyerPercent=tpercent.add(5);
        if (total<=balance)
        {
             max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
             max2buy=max.div(rate).mul(rate);
             return;
        }
        
        lastBuyerPercent=tpercent;
        
        max = myBalance().mul(10000).div(percent.mul(100).add(lastBuyerPercent.mul(100)).add(percent.mul(lastBuyerPercent)).add(10000));
        max2buy=max.div(rate).mul(rate);
    }
   
    
    //делал для проверки соответсвия расчёта бонусов и максимальной покупки (потом можно убрать)
    function needAgetBalanceForSpendWei(uint tospend) public view  returns(uint totaltokens)
    {
        uint tokens = rate.mul(tospend);
      
        uint qbonus=0;
        
        if (tospend >= 1 ether)
        {
            qbonus = tokens.div(20); //если потратили более 1 эфир, то + 5%
        }
        
        if (tospend >= 10 ether)
        {
            qbonus = tokens.div(10);//если потратили более 10 эфир, то + 10%
        }
        
        if (tospend >= 100 ether)
        {
            qbonus =  tokens.mul(15).div(100); //если потратили более 100 эфир, то + 15%
        }
        
        if (tospend >= 1000 ether)
        {
            qbonus = tokens.div(5); //если потратили более 1000 эфир, то + 20%
        }
        
        uint tbonus=0; 
        
        if (now.sub(start) < 3 weeks)
        {
            tbonus=tokens.div(20); //если 3 неделя, то 5%
        }
        
        
        if (now.sub(start) < 2 weeks)
        {
            tbonus=tokens.div(10); //если 2 неделя, то 10%
        }
        
        
        if (now.sub(start) < 1 weeks)
        {
            tbonus=tokens.mul(15).div(100); //если 1 неделя, то 15%
        }
        
        
        if (now.sub(start) < 1 days)
        {
            tbonus=tokens.div(5); //если 1 день, то 20%
        }
        
        
        uint bonused = tokens.add(qbonus).add(tbonus);
        
       
        uint restrictedTokens = bonused.mul(restrictedPercent).div(100);
        uint bountyTokens = bonused.mul(bountyPercent).div(100);
        uint reservedTokens = bonused.mul(reservedPercent).div(100);
        totaltokens=bonused.add(restrictedTokens).add(bountyTokens).add(reservedTokens);
    
    }

    function buyTokens() public canBuy payable {
      
        if (!BlockTimeIsSet)
        {
            token.AddBlockTime(restricted, 1 years);
            token.AddBlockTime(reserved, 1 years);
            BlockTimeIsSet=true;
        }
        uint tokens = rate.mul(msg.value);
      
        uint qbonus=0;
        
        if (msg.value >= 1 ether)
        {
            qbonus = tokens.div(20); //если потратили более 1 эфир, то + 5%
        }
        
        if (msg.value >= 10 ether)
        {
            qbonus = tokens.div(10);//если потратили более 10 эфир, то + 10%
        }
        
        if (msg.value >= 100 ether)
        {
            qbonus =  tokens.mul(15).div(100); //если потратили более 100 эфир, то + 15%
        }
        
        if (msg.value >= 1000 ether)
        {
            qbonus = tokens.div(5); //если потратили более 1000 эфир, то + 20%
        }
        
        uint tbonus=0; 
        
        if (now.sub(start) < 3 weeks)
        {
            tbonus=tokens.div(20); //если 3 неделя, то 5%
        }
        
        
        if (now.sub(start) < 2 weeks)
        {
            tbonus=tokens.div(10); //если 2 неделя, то 10%
        }
        
        
        if (now.sub(start) < 1 weeks)
        {
            tbonus=tokens.mul(15).div(100); //если 1 неделя, то 15%
        }
        
        
        if (now.sub(start) < 1 days)
        {
            tbonus=tokens.div(5); //если 1 день, то 20%
        }
        
        
        uint bonused = tokens.add(qbonus).add(tbonus);
        
       
        uint restrictedTokens = bonused.mul(restrictedPercent).div(100);
        uint bountyTokens = bonused.mul(bountyPercent).div(100);
        uint reservedTokens = bonused.mul(reservedPercent).div(100);
        uint totaltokens=bonused.add(restrictedTokens).add(bountyTokens).add(reservedTokens);
        require( totaltokens <= myBalance());
       
        
      
        InvestmentsStorage ist = InvestmentsStorage(selector.investmentsStorage());
        ist.AddWei.value(msg.value)(msg.sender, stagenum);
        
        token.transferFromAgent(restricted, restrictedTokens);
        token.transferFromAgent(bounty, bountyTokens);
        token.transferFromAgent(reserved, reservedTokens);
        token.transferFromAgent(msg.sender, bonused); 
        

    }
    
    function finalizeSale() public onlyOwner returns (bool)
    {
        if (now > saleEnd() || Max2SpendWei()<1 ) //меньше rate за 1 wei не купишь, такие значения могут оставаться после расчета процентов, поэтому их просто сжигаем  (напоминаю 1 токен на счету - это balances[address]==1*10^18)
        {
           token.burnAllOfAgent();
           return true;
        }
        
        return false;
    }
}