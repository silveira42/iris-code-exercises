Class helloWorld.bp.customersOrders.list.Process Extends Ens.BusinessProcess
{
Method OnRequest(pRequest As helloWorld.bp.customersOrders.list.Request, Output pResponse As helloWorld.bp.customersOrders.list.Response) As %Library.Status
{
    Try {
        Do pRequest.NewResponse(.pResponse)
    } Catch (exception) {
        $$$LOGERROR("Error generating response at OnRequest method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Try {
        Set customers = ..GetCustomers()
    } Catch (exception) {
        $$$LOGERROR("Error getting customers: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Try {
        Set orders = ..GetOrders()
    } Catch (exception) {
        $$$LOGERROR("Error getting orders: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Try {
        Set pResponse.CustomersOrders = ..TransformCustomersOrders(customers, orders)
    } Catch (exception) {
        $$$LOGERROR("Error setting up customer orders: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Return $$$OK
}

Method GetCustomers(filter = "") As helloWorld.bo.customers.list.Response
{
    Set customerRequest = ##class(helloWorld.bo.customers.list.Request).%New()
    $$$ThrowOnError(..SendRequestSync("Customers", customerRequest, .customerResponse))
    Return customerResponse.Customers
}

Method GetOrders(filter = "") As helloWorld.bo.orders.list.Response
{
    Set orderRequest = ##class(helloWorld.bo.orders.list.Request).%New()
    $$$ThrowOnError(..SendRequestSync("Orders", orderRequest, .orderResponse))
    Return orderResponse.Orders
}

Method TransformCustomersOrders(pCustomers As %Collection.ListOfObj, pOrders As %Collection.ListOfObj) As %Collection.ListOfObj
{
    Set customers = pCustomers
    Set orders = pOrders
    Set customersOrders = ##class(%Collection.ListOfObj).%New()

    For i=1:1:customers.Count()
    {
        #Dim customer As helloWorld.obj.customers.Customer = customers.GetAt(i)
        Set customerOrders = ..CreateCustomerOrders(customer, orders)
        Do customersOrders.Insert(customerOrders)
    }

    Return customersOrders
}

Method CreateCustomerOrder(pCustomer As helloWorld.obj.customers.Customer, pOrders As %Collection.ListOfObj) As helloWorld.obj.customers.CustomerOrders
{
    Set customer = pCustomer
    Set orders = pOrders
    Set customerOrder = ##class(helloWorld.obj.customers.CustomerOrders).%New()
    Set customerOrder.Id = customer.Id
    Set customerOrder.Name = customer.Name
    Set customerOrder.Document = customer.Document

    For j=1:1:orders.Count()
    {
        #Dim order As helloWorld.obj.orders.Order = orders.GetAt(j)

        If (customer.Id = order.CustomerId)
        {
            Do customerOrder.Orders.Insert(order)
        }
    }

    Return customerOrder
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
