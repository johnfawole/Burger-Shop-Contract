// SPDX-License-Identifier : MIT

 pragma solidity ^0.8.17;

  contract Burger{
      
      address payable public owner;
      address public customer;

      struct Order{
          uint ID;
          string burgerMenu;
          uint quantity;
          uint price;
          uint safePayment;
          uint orderDate;
          uint deliveryDate;
          bool created;
      }

      struct Invoice{
          uint ID;
          uint orderNo;
          bool created; 
      }


      mapping(uint => Order) orders;
      mapping(uint => Invoice) invoices;

      uint orderseq;
      uint invoiceseq;

      constructor(address payable _buyerAddress) public payable{
          owner = payable(msg.sender);
          customer = _buyerAddress;
        
      }

      function sendOrder(string memory burgerMenu, uint quantity) public payable{
          require(customer == msg.sender, "Only the customers can call this function");
 
          orderseq++;
          
          // we passed the needed members of the struct as params so we can call them
          orders[orderseq] = Order (orderseq, burgerMenu, quantity, 0, 0, 0, 0, true);
      }

      function checkOrder(uint ID) public view returns(address customer, string memory burgerMenu, uint quantity, uint price, uint safePayment) {
          require(orders[ID].created, "The order does not exist ab initio");

          return(customer, orders[ID].burgerMenu, orders[ID].quantity, orders[ID].price, orders[ID].safePayment);
      }

      function sendPrice(uint orderNo, uint price) public payable{
          require(owner == msg.sender, "only the owner can do this, bruh");
          require(orders[orderNo].created, "The specific order does not exist");
          orders[orderNo].price = price;
      }

      function sendSafepayment(uint orderNo) public payable {
          require(customer == msg.sender, "Only customers call this");
          require(orders[orderNo].created, "The specific order does not exist");

          orders[orderNo].safePayment = msg.value;
      }

      function sendInvoice(uint orderNo, uint order_date) public payable {
          require(owner == msg.sender, "only the owner can do this, bruh");
          require(orders[orderNo].created, "The specific order does not exist");
          invoiceseq++;
          invoices[invoiceseq] = Invoice(invoiceseq, orderNo, true);
          orders[orderNo].orderDate = order_date;
      }

      function getInvoice(uint invoiceID) public view returns (address customer, uint orderNo, uint invoice_date) {
          require(invoices[invoiceID].created, "The invoice doesn't exist");
          Invoice storage _invoice = invoices[invoiceID];
          Order storage _order = orders[_invoice.orderNo];
           return(customer, _order.ID, _order.orderDate);
      }

      function markOrderDelivered(uint invoiceID, uint deliveryDate) public payable{
           require(customer == msg.sender, "Only customers can mark orders as delivered");
           require(invoices[invoiceID].created, "The invoice doesn't exist");   
           Invoice storage _invoice = invoices[invoiceID];
           Order storage _order = orders[_invoice.orderNo];
           _order.deliveryDate = deliveryDate;
           owner.transfer(_order.safePayment);

      }
  }
