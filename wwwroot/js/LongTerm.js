$(function () {
    var $tbl = $("#tblCompany");
    $tbl.stickyTableHeaders();

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Company/LongTerm"),
        rpOptions: [5, 10, 20, 30, 40, 50, 100, 200, 500, 1000],
        rp: 1000,
        onSubmit: function (p) {
            p.params = [];
            var chk = $("#chkIsBookMark")[0];
            if (chk.checked) {
                p.params.push({ "name": "IsBookMark", "value": true })
            }
            chk = $("#chkIsArchive")[0];
            if (chk.checked) {
                p.params.push({ "name": "IsArchive", "value": true })
            }
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            var tbody = $("tbody", $tbl);
            tbody.empty();
            $("#grid-template").tmpl(data).appendTo(tbody);
        },
        onPaginationElement: function () {
            return $(".manual-pagination");
        },
        onPaginationStatusElement: function () {
            return $("#paging_status");
        },
        onRPSelectElement: function () {
            return $("#rows2");
        },
        resizeWidth: true,
        method: "GET",
        sortname: "",
        sortorder: "",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });

    $("body").on("click", ".isbookmark-change", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = cInt($("#hdnCompanyID", $tr).val());
        var isBookMark = false;
        if ($this.hasClass('fa-star-o')) {
            isBookMark = true;
        } else {
            isBookMark = false;
        }
        $this.removeClass('fa-star').removeClass('fa-star-o');
        if (isBookMark == true) {
            $this.addClass('fa-star');
        } else {
            $this.addClass('fa-star-o');
        }
        var url = apiUrl("/Company/UpdateBookMark");
        var d = { "CompanyID": companyId, "IsBookMark": isBookMark };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
        }).always(function () {
        });
    });

    $("body").on("click", "#frmSearch #chkIsBookMark", function () {
        $tbl.flexReload2();
    });

    $("body").on("click", "#frmSearch #chkIsArchive", function () {
        $tbl.flexReload2();
    });

});