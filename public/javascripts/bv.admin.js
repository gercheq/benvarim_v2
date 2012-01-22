Bv.Admin = {
    users : null,
    projects : null,
    organizations : null,
    loadUsers : function(callback) {
        this._load("user", callback);
    },
    loadProjects : function(callback) {
        this._load("project", callback);
    },
    loadOrganizations : function(callback) {
        this._load("organization", callback);
    },
    _load : function(type, callback) {
        var types = type + "s";
        var that = this;
        if(this[types] != null) {
            callback(this[types]);
            return;
        }
        
        $.get("/kertenkele/" + type + "_list.json", {}, function(data) {
            if(!data || !data[types]) {
                alert(types + " yükleyemedim");
                callback(null);
                return;
            }
            that[types] = data[types];
            callback(that[types]);
        });
    }
    
};