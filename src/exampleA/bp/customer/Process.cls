Class exampleA.bp.customer.Process Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As exampleA.bp.customer.Request, Output pResponse As exampleA.bp.customer.Response) As %Library.Status
{
    /// Juntar try catches para tratamento centralizado de erros
    Try {
        Do pRequest.NewResponse(.pResponse)
    } Catch (exception) {
        /// Gerenciamento dos logs de erro
        $$$LOGERROR("Error generating response at OnRequest method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Try {
        If (pRequest.action = "create") {
            Set pResponse = ..HandleCreate(pRequest.Customer)
        } Else {
            Do ..HandleUpdate(pRequest.Customer)
        }
    } Catch (exception) {
        $$$LOGERROR("Error handling request at OnRequest method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }

    Return $$$OK
}

Method HandleCreate(pCustomer As exampleA.obj.customers.Customer) As exampleA.obj.customers.Customer
{
    Set customerRequest = ##class(exampleA.bo.customers.create.Request).%New()
    Set customerRequest.Customer = pCustomer

    /// Modo 1
    Set sc = ..SendRequestSync("Customers", customerRequest, .customerResponse)
    If ($SYSTEM.Status.IsError(sc))
    {
        Throw ##class(%Exception.StatusException).CreateFromStatus(sc)
    }

    /// Modo 2
    Set sc = ..SendRequestSync("Customers", customerRequest, .customerResponse)
    $$$ThrowOnError(sc)

    /// Modo 3
    $$$ThrowOnError(..SendRequestSync("Customers", customerRequest, .customerResponse))
   
    #Dim customerResponse As exampleA.bo.customers.create.Response

    #Dim customer As exampleA.obj.customers.Customer = customerResponse.Customer

    Return customer
}

Method HandleUpdate(pCustomer As exampleA.obj.customers.Customer) As exampleA.obj.customers.Customer
{
    Set customerRequest = ##class(exampleA.bo.customers.update.Request).%New()
    Set customerRequest.Customer = pCustomer

    $$$ThrowOnError(..SendRequestSync("Customers", customerRequest, .customerResponse))
    #Dim customerResponse As exampleA.bo.customers.update.Response

    #Dim customer As exampleA.obj.customers.Customer = customerResponse.Customer

    Return customer
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
