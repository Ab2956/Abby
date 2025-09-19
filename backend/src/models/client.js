class Client{
    constructor(client_id, name , taxRef){
        this.client_id = client_id;
        this.name = name;
        this.taxRef = taxRef;
        this.obligations = new Map()
        this.submisions = [];
    }
}