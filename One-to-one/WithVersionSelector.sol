pragma solidity ^0.4.20;

import 'browser/IVersionSelector.sol';


/**
* Контракт предназначен для хранения адреса контракта,
* который имеет ссылки на все контракты системы - VersionSelector
*/
contract WithVersionSelector
{
    //Контракт IVersionSelector
    IVersionSelector internal selector;
    
    //Конструктор
    //@param _selector адрес контракта IVersionSelector 
    function WithVersionSelector(address _selector) public {
        require(_selector != 0x0);
        selector=IVersionSelector(_selector);
    }
}
