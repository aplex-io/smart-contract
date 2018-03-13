pragma solidity ^0.4.20;

/**
* Менять контракты нельзя,но выпускать новые версии можно
* Сайты, приложения, сервисы начинают общаться c сетью блокчейна
* с получения адресов актуальных контрактов. В общем случе в данном контракте 
* мы храним адреса всех используемых в системе контрактов других типов
* При реализации системы контрактов продажи токенов мы ограничиваем возможности 
* замены версий контрактов, чтобы гарантировать объявленные условия продажи
* 
* Данный контракт является виртуальным и объявляет минимальные 
* требования к контракту VersionSelecor, необходимые для функционирования
* в системе продажи токенов APLEX
*/
contract IVersionSelector  {
    //адрес токена APLX
    address public curAPLXTokenAddress;
    
    //адрес токена APLC
    address public curAPLCTokenAddress;
    
    //адрес контракта маркета (пока ен используется)
    address public curMarketAddress;
    
    //адрес текущего агента распродажи
    address public curSaleAgentAddress;
    
    //адрес контракта, собирающего инвестиции и управляющего ими
    address public investmentsStorage;

    //установка адреса контракта маркета (пока не используется) 
    function setCurMarketAddress(address _newaddr)  public ;
    
    //установка адреса контракта токенв APLX
    function setCurAPLXTokenAddress(address _newaddr)  public ;
    
    //установка адреса контракта токена APLC   
    function setCurAPLCTokenAddress(address _newaddr)  public ;
    
    //установка адреса текущего агента продажи
    function setCurSaleAgentAddress(address _newaddr)  public ;
  
    //снятие блокировки обмена APLX на APLC
    function UnblockExchangeAPLX()  public;
     
    //получение баланса текущего агента продажи 
    function getsaleAgentBalance() public view returns(uint agentbal);
  
}