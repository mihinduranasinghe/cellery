import ballerina/io;
import celleryio/cellery;
import anuruddhal/employee;
import anuruddhal/stock;


//HR component
cellery:Component hrComponent = {
    name: "hr",
    source: {
        image: "docker.io/celleryio/sampleapp-hr"
    },
    ingresses: {
        "hr": new cellery:HTTPIngress(8080, {
                basePath: "/",
                definitions: [{
                    path: "/info",
                    method: "GET"
                }]
            }
        )
    },
    parameters: {
        employeegw_url: new cellery:Env(),
        stockgw_url: new cellery:Env()
    }

};

// Cell Intialization
cellery:CellImage hrCell = new();

public function build(string imageName, string imageVersion) {
    // Build HR cell
    io:println("Building HR Cell ...");
    hrCell.addComponent(hrComponent);

    // Expose API from Cell Gateway & Global Gateway
    hrCell.exposeGlobalAPI(hrComponent);
    _ = cellery:createImage(hrCell, imageName, imageVersion);
}


public function run(string imageName, string imageVersion, string instanceName) {
    employee:EmployeeReference employeeRef = new(instanceName = "employee");
    stock:StockReference stockRef = new(instanceName = "stock");
    cellery:setParameter(hrComponent.parameters.employeegw_url, employeeRef.getHost());
    cellery:setParameter(hrComponent.parameters.stockgw_url, stockRef.getHost());
    hrCell.addComponent(hrComponent);
    _ = cellery:createInstance(hrCell, imageName, imageVersion, instanceName);
}

