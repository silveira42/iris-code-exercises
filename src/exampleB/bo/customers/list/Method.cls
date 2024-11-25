Include Ensemble

/// Comentário que aparece na documentação
Class exampleB.bo.customers.list.Method [ Abstract ]
{

/// Comentário que aparece na documentação
ClassMethod Execute(pHost As exampleB.bo.customers.Operation, pRequest As exampleB.bo.customers.list.Request, Output pResponse As exampleB.bo.customers.list.Response) As %Library.Status
{
    Try {
        Do pRequest.NewResponse(.pResponse)
    } Catch (exception) {
        $$$LOGERROR("Error generating response at list method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

	Set httpRequest = ##class(%Net.HttpRequest).%New()

	Set httpRequest.ContentCharset	= "UTF-8"
	Set httpRequest.ContentType		= "application/json"

    Set urlCustomers = "https://run.mocky.io/v3/b780cff1-b40c-484f-95c4-ba44e1b78be5"

    Try {
        $$$ThrowOnError(pHost.Adapter.SendFormDataArray(.httpResponseCustomers, "GET", httpRequest , "", , urlCustomers))
    } Catch(exception) {
        $$$LOGERROR("Error sending customer request at list method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

	Set httpResponseBody = ""

    Try {
        Set dynamicCustomers = ##class(%Library.DynamicObject).%FromJSON(httpResponseCustomers.Data)
    } Catch(exception) {
        $$$LOGINFO(httpResponseCustomers.Data)
        $$$LOGERROR("Error reading customer response at list method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Set urlOrders = "https://run.mocky.io/v3/5d27c152-ebf8-4e85-8852-da10852230f2"

    Try {
        $$$ThrowOnError(pHost.Adapter.SendFormDataArray(.httpResponseOrders, "GET", httpRequest , "", , urlOrders))
    } Catch(exception) {
        $$$LOGERROR("Error sending order request at list method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

	Set httpResponseBody = ""

    Try {
        Set dynamicOrders = ##class(%Library.DynamicObject).%FromJSON(httpResponseOrders.Data)
    } Catch(exception) {
        $$$LOGINFO(httpResponseOrders.Data)
        $$$LOGERROR("Error reading order response at list method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Set customerIter = dynamicCustomers.%GetIterator()
    While customerIter.%GetNext(.customerKey, .customer) {
        #Dim customerToReturn As exampleB.obj.customers.Customer = customer

        Set orderIter = dynamicOrders.%GetIterator()
        While orderIter.%GetNext(.orderKey, .order) {
            #Dim order As exampleB.obj.orders.Order

            If (customer.Id = order.CustomerId) {
                Do customerToReturn.Insert(order)
            }
        }

        Do pResponse.Customers.Insert(customerToReturn)
    }

    Return $$$OK
}

}
