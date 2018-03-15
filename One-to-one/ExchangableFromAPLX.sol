pragma solidity ^0.4.20;

import 'browser/WithVersionSelector.sol';
import 'browser/MintableToken.sol';

/**
* Контракт обеспечивающий выпуск токенов при обмене APLX на APLC
* на счёт меняющего 
*/
contract ExchangableFromAPLX is MintableToken, WithVersionSelector
{
    using SafeMath for uint;
    
    //Конструктор
    function ExchangableFromAPLX(address _versionSelectorAddress) public WithVersionSelector(_versionSelectorAddress)
    {
        
    }
    
    //выпуск токенов при обмене APLX на APLC на счёт меняющего (holder) 
    //в количестве в amount
    //функция вызывается токеном APLX
    function MintForExchange(address holder, uint amount)  public
    {
        //проверка, что функция вызывается токеном APLX
        require(address(selector)!=0x0 && selector.curAPLXTokenAddress()==msg.sender);
        //корректировка общего количества выпущенных токенов
        totalSupply = totalSupply.add(amount);
        //Выпуск на счёт holder-а
        balances[holder] = balances[holder].add(amount);
        //Событие Mint
        Mint(holder, amount);
        //Событие Transfer (0->holder)
        Transfer(address(0), holder, amount);
    }
}