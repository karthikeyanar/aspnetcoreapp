function SecurityTypeModel() {
    this.save = function() {
        var url = apiUrl("/SecurityType/Save");
        //form encoded data
        var dataType = 'application/x-www-form-urlencoded; charset=utf-8';
        var data = null;

        //JSON data
        var dataType = 'application/json; charset=utf-8';
        var data = {
            SecurityTypeID: 0,
            Name: 'Test'
        }

        console.log('Submitting form...');
        $.ajax({
            type: 'POST',
            url: url,
            dataType: 'json',
            contentType: dataType,
            data: JSON.stringify(data),
            success: function(result) {
                console.log('Data received: ');
                console.log(result);
            }
        });

    }
}

$(function() {
    var $tbl = $("#tblSecurityType");
    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/SecurityType/List"),
        rpOptions: [1, 10, 20, 30, 40, 50, 100, 200],
        rp: 1,
        onSubmit: function(p) {},
        onSuccess: function(t, g) {},
        onTemplate: function(data) {
            var tbody = $("tbody", $tbl);
            tbody.empty();
            $("#grid-template").tmpl(data).appendTo(tbody);
        },
        onPaginationElement: function() {
            return $(".manual-pagination");
        },
        onPaginationStatusElement: function() {
            return $("#paging_status");
        },
        onRPSelectElement: function() {
            return $("#rows2");
        },
        resizeWidth: true,
        method: "GET",
        sortname: "Name",
        sortorder: "asc",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });




});