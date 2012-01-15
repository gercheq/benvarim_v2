Bv.Admin = {
    users : null,
    loadUsers : function(callback) {
        if(this.users != null) {
            callback(this.users);
            return;
        }
        var that = this;
        $.get("/kertenkele/user_list.json", {}, function(data) {
            if(!data || !data.users) {
                alert("Kullanıcıları yükleyemedim");
                callback(null);
                return;
            }
            that.users = data.users;
            callback(that.users);
        });
    }
};