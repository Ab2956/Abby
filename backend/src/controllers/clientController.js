let clients = [];

exports.createClient = (req, res) =>{
    const {client_id, name, vatNumber} = req.body;

    const exists = clients.find(c => c.client_id === client_id);

    const newClient = {client_id, name, vatNumber};
    clients.push(newClient);

    res.status(201).json({
        message: "Client created",
        client: newClient
    })
};

exports.getAllClients = (req, res) => {
    res.json(clients);
};

exports.getClientById = (res, req) => {
    const {client_id} = req.params;
    const client = clients.find(c => c.client_id === client_id);

    res.json(client);
}