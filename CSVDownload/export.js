function tableStructure() {
    this.cols = [];
    this.rows = [];
}

function removeHTML(html) {
    var regex = /(<([^>]+)>)/ig,
        body = html,
        result = body.replace(regex, "");

    return $.trim(result); //.replace(/\s+$/g, "").replace(/(\r\n|\n|\r)/gm, "").replace(/\s+/g, "");
}

// The download function takes a CSV string, the filename and mimeType as parameters
// Scroll/look down at the bottom of this snippet to see how download is called
var download = function (content, fileName, mimeType) {
    var a = document.createElement('a');
    mimeType = mimeType || 'application/octet-stream';

    if (navigator.msSaveBlob) { // IE10
        navigator.msSaveBlob(new Blob([content], {
            type: mimeType
        }), fileName);
    } else if (URL && 'download' in a) { //html5 A[download]
        a.href = URL.createObjectURL(new Blob([content], {
            type: mimeType
        }));
        a.setAttribute('download', fileName);
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    } else {
        location.href = 'data:application/octet-stream,' + encodeURIComponent(content); // only this mime type is supported
    }
}

function exportTable(tabid, openerId) {
    window.alert = function () { };
    var $tbl = $("table:eq(3)");
    var symbol = '';
    try {
        var $title = $("title");
        var html = $title.html();
        var myRegexp = /NSE:\s*(?<symbol>.*)/g;
        var match = myRegexp.exec(html);
        symbol = match[1];
    } catch (e) {
        ////console.log(e);
    }
    //////console.log($tbl[0]);
    var colRowIndex = 0;
    var cols = '';
    var struct = new tableStructure();
    var isStop = false;
    $("tbody > tr", $tbl).each(function (i) {
        if (isStop == false) {
            colRowIndex = i;
            var $tr = $(this);
            $("td.detb.brdL.brdR", $tr).each(function (z) {
                isStop = true;
                var $td = $(this);
                var value = removeHTML($td.html());
                if (z == 0) {
                    value = symbol;
                }
                if (value.indexOf('Jun') >= 0) {
                    value = value.replace('Jun \'', '06/01/');
                } else if (value.indexOf('Mar') >= 0) {
                    value = value.replace('Mar \'', '03/01/');
                } else if (value.indexOf('Dec') >= 0) {
                    value = value.replace('Dec \'', '12/01/');
                } else if (value.indexOf('Sep') >= 0) {
                    value = value.replace('Sep \'', '09/01/');
                }
                struct.cols.push(value);
            });
        } else {
            return false;
        }
    });
    //////console.log('colRowIndex=', colRowIndex);
    $("tbody > tr", $tbl).each(function (j) {
        //////console.log('j=', j);
        if (colRowIndex < j) {
            var $tr = $(this);
            var row = [];
            $("td.det.brdL.brdR", $tr).each(function (i) {
                var $td = $(this);
                var value = removeHTML($td.html());
                value = value.replace('--', '').replace('&amp;', '&');
                ////////console.log('i=', i, 'value=', value);
                if (i < struct.cols.length) {
                    row.push(value);
                }
            });
            if (row.length > 0) {
                struct.rows.push(row);
            }
        }
    });
    //////console.log(struct);
    var csvContent = convertCSVContent(struct, '\n');
    var fileName = '';
    if (struct.cols.length > 0) {
        fileName += struct.cols[0] + '-' + struct.cols[1] + '-' + struct.cols[struct.cols.length - 1] + '.csv';
    }
    ////console.log('fileName=', fileName);
    download(csvContent, fileName, 'text/csv;encoding:utf-8');
    setTimeout(function () {
        //chrome.runtime.sendMessage({ cmd: 'mc-quaterly-downloaded','tabid':openerId  });
        chrome.runtime.sendMessage({ cmd: 'close_tab', 'tabid': tabid, 'openerid': openerId });
    }, 1000);
}

function investingNifty500(tabid, openerId) {
    window.alert = function () { };
    var $tbl = $("#cr1");
    var symbol = '';
    try {
        var $title = $("title");
        var html = $title.html();
        var myRegexp = /NSE:\s*(?<symbol>.*)/g;
        var match = myRegexp.exec(html);
        symbol = match[1];
    } catch (e) {
        ////console.log(e);
    }
    console.log($tbl[0]);
    var colRowIndex = 0;
    var cols = '';
    var struct = new tableStructure();
    struct.cols.push("CompanyName");
    struct.cols.push("URL");
    var isStop = false;
    $("tbody > tr", $tbl).each(function (i) {
        var row = [];
        var $tr = $(this);
        var $td2 = $("td:eq(1)", $tr);
        var $a = $("a", $td2);
        var companyName = $.trim($a.html());
        var url = $.trim($a.attr('href'));
        row.push(companyName);
        row.push(url);

        struct.rows.push(row);
    });
    console.log(struct);
    var csvContent = convertCSVContent(struct, '\n');
    var fileName = 'Nifty500_Investing.csv';
    ////console.log('fileName=', fileName);
    download(csvContent, fileName, 'text/csv;encoding:utf-8');
    //setTimeout(function(){
    //chrome.runtime.sendMessage({ cmd: 'mc-quaterly-downloaded','tabid':openerId  });
    //    chrome.runtime.sendMessage({ cmd: 'close_tab','tabid':tabid,'openerid':openerId  });
    //},1000);
}

function investingHistory(tabid, openerId, companyId, startDate, endDate, index, total) {
    window.alert = function () { };
    var $flatDatePickerCanvasHol = $("#flatDatePickerCanvasHol");
    //var $picker = $("#picker", $flatDatePickerCanvasHol);
    //console.log('$picker=', $picker[0]);
    //$picker[0].value = startDate.toString() + ' - ' + endDate.toString();
    //var $data_interval = $("#data_interval");
    //$data_interval[0].value = 'Monthly';
    console.log('tabid=', tabid, 'openerId=', openerId, 'companyId=', companyId, 'startDate=', startDate, 'endDate=', endDate, 'index=', index, 'total=', total);
    setTimeout(function () {
        /* var $historicalDataTimeRange = $(".historicalDataTimeRange");
        var $datePickerIconWrap = $("#datePickerIconWrap", $historicalDataTimeRange);
        console.log('datePickerIconWrap=', $datePickerIconWrap[0]);
        $datePickerIconWrap.click(); */
        //setTimeout(function () {
          /*   var $uiDatepickerDiv = $("#ui-datepicker-div");
            var $startDate = $("#startDate", $uiDatepickerDiv);
            var $endDate = $("#endDate", $uiDatepickerDiv);
            var $applyBtn = $("#applyBtn", $uiDatepickerDiv);
            console.log('uiDatepickerDiv=', $uiDatepickerDiv[0]);
            console.log('startDate=', $startDate[0]);
            console.log('endDate=', $endDate[0]);
            console.log('applyBtn=', $applyBtn[0]);
            simulateClick($applyBtn[0]); */

            //setTimeout(function () {

                var $curr_table = $(".common-table.js-table.medium");
                console.log('$curr_table=',$curr_table[0]);
                var $tbody = $("tbody", $curr_table);
                console.log('$tbody=',$tbody[0]);

                var struct = new tableStructure();
                struct.cols.push("CompanyID");
                struct.cols.push("Date");
                struct.cols.push("Close Price");
                struct.cols.push("Open Price");
                struct.cols.push("High Price");
                struct.cols.push("Low Price");
                struct.cols.push("Volume");
                struct.cols.push("Change");

                $("tr", $tbody).each(function (i) {
                    var row = [];
                    var $tr = $(this);
                    row.push(companyId);
                    var dtext = $("td:eq(0)>.text", $tr).text();
                    //console.log('dtext=',dtext);
                    //var arr = dtext.split(' ');
                    //console.log('arr=',arr);
                    //var dt = '01/' + arr[0] + '/' + arr[1];
                    //console.log('dt=',dt);
                    row.push(dtext); // date
                    row.push($("td:eq(1)>.text", $tr).text()); // close price
                    row.push($("td:eq(2)>.text", $tr).text()); // open price
                    row.push($("td:eq(3)>.text", $tr).text()); // high price
                    row.push($("td:eq(4)>.text", $tr).text()); // low price
                    row.push($("td:eq(5)>.text", $tr).text()); // volume
                    row.push($("td:eq(6)>.text", $tr).text()); // change

                    struct.rows.push(row);
                });

                var csvContent = convertCSVContent(struct, '\n');

                var csv = convertCSVContent(struct, '|');

                var code = "$('#investing_index').val('" + (index + 1) + "');$('#investing_total').val('" + total + "');$('#investing_csv').val('" + csv + "');$('#btnInvestingUpdateCSV').click();";
                chrome.runtime.sendMessage({ cmd: 'execute_code', 'tabid': openerId, 'code': code });

                var fileName = $.trim($('.main-title.js-main-title > span').text()) + '-' + companyId + '-' + startDate.toString() + '-' + endDate.toString() + '.csv';
                ////console.log('fileName=', fileName);
                //download(csvContent, fileName, 'text/csv;encoding:utf-8');

                setTimeout(function () {
                    chrome.runtime.sendMessage({ cmd: 'investing_close_tab', 'tabid': tabid, 'openerid': openerId });
                }, 1000);

            //}, 5000);
        //}, 2000);
    }, 5000);
}

function technicalHistory(tabid, openerId, companyId, startDate, endDate, index, total) {
    window.alert = function () { };
    setTimeout(function () {
        var $timePeriodsWidget = $("#timePeriodsWidget");
        if ($timePeriodsWidget[0]) {
            $("li", $timePeriodsWidget).each(function () {
                var html = $("a", this).html();
                if (html == 'Daily') {
                    $(this).click();
                    setTimeout(function () {
                        var $tbl = $(".movingAvgsTbl");
                        var $tbody = $("tbody", $tbl);
                        var $last_last = $("#last_last");
                        var content = companyId + '^' + $last_last.html() + '^';
                        $("tr", $tbody).each(function (i) {
                            var $tr = $(this);
                            var $td0 = $("td:eq(0)", $tr);
                            var $td1 = $("td:eq(1)", $tr);
                            var $td2 = $("td:eq(2)", $tr);
                            if ($td0[0] && $td1[0] && $td2[0]) {
                                var content1 = removeHTML($td0.html());
                                var content2 = removeHTML($td1.html());
                                //var content3 = removeHTML($td2.html());
                                //console.log('content1=', content1, 'content2=', content2);//, 'content3=', content3);
                                content += content1 + '|' + content2 + '~'; // + content3 + '~';
                            }
                        });
                        content = content.replace(/\n/g, "");
                        content = content.replace(/\r/g, "");
                        content = content.replace(/' '/g, "");
                        if (content != '') {
                            content = content.substring(0, content.length - 1);
                        }
                        console.log('content=', content);
                        var code = "$('#technical_index').val('" + (index + 1) + "');$('#technical_total').val('" + total + "');$('#technical_csv').val('" + content + "');$('#btnTechnicalUpdateCSV').click();";
                        chrome.runtime.sendMessage({ cmd: 'execute_code', 'tabid': openerId, 'code': code });

                        //var fileName = $.trim($('.float_lang_base_1.relativeAttr').text()) + '-' + companyId + '-' + startDate.toString() + '-' + endDate.toString() + '.csv';
                        ////console.log('fileName=', fileName);
                        //download(csvContent, fileName, 'text/csv;encoding:utf-8');

                        setTimeout(function () {
                            chrome.runtime.sendMessage({ cmd: 'technical_close_tab', 'tabid': tabid, 'openerid': openerId });
                        }, 1000);

                    }, 3000);
                }
            });
        } else {
            var content = '';
            var code = "$('#technical_index').val('" + (index + 1) + "');$('#technical_total').val('" + total + "');$('#technical_csv').val('" + content + "');$('#btnTechnicalUpdateCSV').click();";
            chrome.runtime.sendMessage({ cmd: 'execute_code', 'tabid': openerId, 'code': code });

            //var fileName = $.trim($('.float_lang_base_1.relativeAttr').text()) + '-' + companyId + '-' + startDate.toString() + '-' + endDate.toString() + '.csv';
            ////console.log('fileName=', fileName);
            //download(csvContent, fileName, 'text/csv;encoding:utf-8');

            setTimeout(function () {
                chrome.runtime.sendMessage({ cmd: 'technical_close_tab', 'tabid': tabid, 'openerid': openerId });
            }, 1000);
        }
    }, 2000);
}

function screenerHistory(tabid, openerId, companyId, index, total) {
    window.alert = function () { };
    console.log('tabid=', tabid, 'openerId=', openerId, 'companyId=', companyId, 'index=', index, 'total=', total);
    setTimeout(function () {
        var values = '';
        values += 'CompanyID' + '~' + companyId + '~' + '' + '|';
        $("li.four.columns").each(function () {
            var $li = $(this);
            $("i", $li).remove();
            var $b1 = $("b:eq(0)", $li);
            var $b2 = $("b:eq(1)", $li);
            var b1Value = '';
            var b2Value = '';
            if ($b1[0]) {
                b1Value = $.trim($b1.html());
            }
            if ($b2[0]) {
                b2Value = $.trim($b2.html());
            }
            $b1.remove();
            $b2.remove();
            var name = $.trim($li.html());
            values += name + '~' + b1Value + '~' + b2Value + '|';
        });
        var $section = $("section[id='quarters']");
        var $tbl = $("table", $section);
        values += getCells($tbl, 'Net Profit', 'quater_profit');
        values += getCells($tbl, 'Sales', 'quater_sales');
        $section = $("section[id='profit-loss']");
        var $tbl = $("table", $section);
        values += getCells($tbl, 'Net Profit', 'year_profit');
        values += getCells($tbl, 'Sales', 'year_sales');

        var csv = values;
        csv = csv.replace(/\n/g, "");
        csv = csv.replace(/\r/g, "");
        csv = csv.replace(/' '/g, "");
        console.log('csv=', csv);
        var code = "$('#screener_index').val('" + (index + 1) + "');$('#screener_total').val('" + total + "');$('#screener_csv').val('" + csv + "');$('#btnScreenerUpdateCSV').click();";
        chrome.runtime.sendMessage({ cmd: 'execute_code', 'tabid': openerId, 'code': code });

        var fileName = 'Screener_' + companyId + '_Fundamental.txt';
        console.log('fileName=', fileName);
        download(csv, fileName, 'text/csv;encoding:utf-8');

        setTimeout(function () {
            chrome.runtime.sendMessage({ cmd: 'screener_close_tab', 'tabid': tabid, 'openerid': openerId });
        }, 1000);

    }, 2000);
}

function getCells($tbl, key, name) {
    var values = '';
    $("tbody > tr", $tbl).each(function () {
        var $tr = $(this);
        var $tdFirst = $("td:eq(0)", $tr);
        var profits = '';
        console.log('tdFirst', $tdFirst[0]);
        if ($tdFirst[0]) {
            if ($tdFirst.html().indexOf(key) > -1) {
                $("td", $tr).each(function (i) {
                    console.log('i=', i);
                    if (i > 0) {
                        profits += $(this).text() + ';';
                    }
                });
            }
            if (profits != '') {
                profits = profits.substring(0, profits.length - 1);
            }
            if (profits != '') {
                values += name + '~' + profits + '~' + '' + '|';
            }
        }
    });
    console.log('values=', values);
    return values;
}

function removeHTMLTags(content) {
    var cleanText = '';
    cleanText = $.trim(content.replace(/>\s*</g, "> <").toString());
    //console.log('cleanText 1=', cleanText);
    cleanText = $.trim(cleanText.replace(/<\/?[^>]+(>|$)/g, '').toString());
    //cleanText = $.trim(cleanText.replace(/\n/g, "").toString());
    //console.log('cleanText 2=', cleanText);
    return cleanText;
}

function moneycontrolHistory(tabid, openerId, companyId, index, total) {
    window.alert = function () { };
    console.log('tabid=', tabid, 'openerId=', openerId, 'companyId=', companyId, 'index=', index, 'total=', total);
    setTimeout(function () {
        var $tbldata24 = $(".tbldata24");
        var $tbl = $("table", $tbldata24);
        var totalCol = 8;
        var csv = '';
        var isStart = false;
        $("tbody > tr", $tbl).each(function () {
            var $tr = $(this);
            var cols = '';
            var isNotAppend = false;
            for (var i = 0; i < totalCol; i++) {
                var value = '';
                var $td = $("td:eq(" + i + ")", $tr);
                if (!$td[0]) {
                    $td = $("th:eq(" + i + ")", $tr);
                }
                if ($td[0]) {
                    value = removeHTMLTags($td.html());
                } else {
                    value = '';
                }
                if (value.indexOf('(C) Shares held by Custodians and against which Depository') > -1 ||
                    value.indexOf('(2) Non-Institutions') > -1) {
                    isStart = false;
                }
                if (isStart == true) {
                    if (value.indexOf('(1) Institutions') > -1
                        || value.indexOf('Sub Total') > -1) {
                        isNotAppend = true;
                    }
                }
                if (isStart == true && isNotAppend == false) {
                    cols += value + '|';
                }
                if (value.indexOf('(B) Public Shareholding') > -1) {
                    isStart = true;
                    isNotAppend = true;
                }
            }
            if (isStart == true) {
                if (cols != '') {
                    csv += companyId + '|' + cols + ';'
                }
            }
        });
        if (csv != '') {
            csv = csv.substring(0, csv.length - 1);
        }
        console.log('csv=', csv);


        var fileName = 'MoneyControl_Share_Holding_' + companyId + '.txt';
        console.log('fileName=', fileName);
        download(csv, fileName, 'text/csv;encoding:utf-8');

        setTimeout(function () {
            chrome.runtime.sendMessage({ cmd: 'moneycontrol_close_tab', 'tabid': tabid, 'openerid': openerId });
        }, 1000);


        var code = "$('#moneycontrol_index').val('" + (index + 1) + "');$('#moneycontrol_total').val('" + total + "');$('#moneycontrol_csv').val('" + csv + "');$('#btnMoneyControlUpdateCSV').click();";
        chrome.runtime.sendMessage({ cmd: 'execute_code', 'tabid': openerId, 'code': code });

    }, 2000);
}


function simulateClick(element) {
    // DOM 2 Events
    var dispatchMouseEvent = function (target, var_args) {
        try {
            var e = document.createEvent("MouseEvents");
            // If you need clientX, clientY, etc., you can call
            // initMouseEvent instead of initEvent
            e.initEvent.apply(e, Array.prototype.slice.call(arguments, 1));
            target.dispatchEvent(e);
        } catch (exc) {
            console.log('simulateClick exc=', exc);
        }
    };
    dispatchMouseEvent(element, 'mouseover', true, true);
    dispatchMouseEvent(element, 'mousedown', true, true);
    dispatchMouseEvent(element, 'click', true, true);
    dispatchMouseEvent(element, 'mouseup', true, true);
}

function sendKeys($txt, value, isfocus) {
    //console.log('$txt=', $txt[0], 'value=', value);
    if (isfocus == true) {
        $txt.focus();
    }
    $txt.sendkeys(value);
}

function pageLoad(pageUrl, tabId, openerId, symbol) {
    ////console.log('pageLoad pageUrl=',pageUrl,'tabId=',pageUrl,'openerId=',openerId);
    nseStart(pageUrl, tabId, openerId, symbol);
}

function convertCSVContent(struct, newlinechar) {
    var content = '';
    var cols = '';
    var rows = '';
    for (var i = 0; i < struct.cols.length; i++) {
        cols += '"' + struct.cols[i] + '",';
    }
    if (cols != '') {
        cols = cols.substring(0, cols.length - 1);
    }
    cols = cols + newlinechar;

    for (var i = 0; i < struct.rows.length; i++) {
        var row = '';
        for (var j = 0; j < struct.rows[i].length; j++) {
            row += '"' + struct.rows[i][j] + '",';
        }
        if (row != '') {
            row = row.substring(0, row.length - 1);
        }
        rows += row + newlinechar;
    }

    content = cols + rows;
    //////console.log(content);
    return content;
}

var _NSE = null;
/* */
function nseStart(pageUrl, tabId, openerId, symbol) {
    ////console.log('nseStart tabId=',tabId,'openerId=',openerId,'symbol=',symbol);
    _NSE = new NSE();
    _NSE.init(pageUrl, tabId, openerId, symbol);
}
/* */

function NSE() {

    var self = this;
    this.tabId = 0;
    this.openerId = 0;
    this.pageUrl = '';
    this.symbol = '';
    this.symbolsArray = [];
    this.index = -1;

    this.init = function (pageUrl, tabId, openerId, symbol) {
        ////console.log('NSE init tabId=',tabId,'openerId=',openerId,'symbol=',symbol);
        self.tabId = parseInt(tabId);
        self.openerId = parseInt(openerId);
        self.pageUrl = pageUrl;
        self.symbol = symbol;
        self.symbolsArray = self.symbol.split(',');
        self.index = -1;
        self.downloadData();
        //var code = "$('#btnNSEDownloadBackground').attr('tabid',"+self.tabId+");$('#btnNSEDownloadBackground').click();";
        //chrome.runtime.sendMessage({ cmd: 'execute_code','tabid':openerId,'code':code  });
    }

    this.downloadData = function () {
        var symbol = ''; var startDate = ''; var endDate = ''; var nseType = '';
        self.index += 1;
        console.log('self.index=', self.index, ',total=', self.symbolsArray.length);
        if (self.index <= self.symbolsArray.length) {
            var arr = self.symbolsArray[self.index].split('|');
            symbol = arr[0];
            startDate = arr[1];
            endDate = arr[2];
            nseType = arr[3];
            if (nseType == '') {
                nseType = 'EQ';
            }
            console.log('download symbol=', symbol, 'startDate=', startDate, 'endDate=', endDate, 'nseType=', nseType);
            var $frm = $("#histForm");
            var $dataType = $("#dataType", $frm);
            var $symbol = $("#symbol", $frm);
            var $series = $("#series", $frm);
            var $rdDateToDate = $("#rdDateToDate", $frm);
            var $csvFileName = $('#csvFileName');
            var $csvContentDiv = $('#csvContentDiv');

            $csvFileName.val('');
            $csvContentDiv.val('');

            $dataType.val('priceVolume');
            $symbol.val(symbol);
            $series.val(nseType);
            $rdDateToDate[0].checked = true;

            var $fromDate = $("#fromDate", $frm);
            $fromDate.val(startDate);
            var $toDate = $("#toDate", $frm);
            $toDate.val(endDate);

            var $btn = $(".getdata-button", $frm);
            $btn.click();

            setTimeout(function () {
                $csvFileName = $('#csvFileName');
                $csvContentDiv = $('#csvContentDiv');
                var csv = '';
                var fileName = '';
                ////console.log('$csvFileName=',$csvFileName[0]);
                ////console.log('$csvContentDiv=',$csvContentDiv[0]);
                if ($csvFileName[0]) {
                    if ($csvFileName.val() != '') {
                        fileName = $csvFileName.val();
                        csv = $csvContentDiv.html();
                    }
                }
                //console.log('fileName=',fileName);
                //console.log('csv=',csv);
                if (csv != '') {
                    //csv=csv.replace(/:/g,"\n");
                    var code = "$('#nse_index').val('" + (self.index + 1) + "');$('#nse_total').val('" + self.symbolsArray.length + "');$('#nse_csv').val('" + csv + "');$('#btnNSEUpdateCSV').click();";
                    chrome.runtime.sendMessage({ cmd: 'execute_code', 'tabid': self.openerId, 'code': code });
                    setTimeout(function () {
                        csv = csv.replace(/:/g, "\n");
                        var csvFile;
                        var downloadLink;
                        csvFile = new Blob([csv], {
                            type: "text/csv"
                        });
                        downloadLink = document.createElement("a");
                        downloadLink.download = fileName;
                        downloadLink.href = window.URL.createObjectURL(csvFile);
                        downloadLink.style.display = "none";
                        document.body.appendChild(downloadLink);
                        downloadLink.click();
                    }, 500);
                    setTimeout(function () {
                        self.downloadData();
                    }, 1000);
                } else {
                    var $missingSymbols = $("#missing_symbols");
                    if (!$missingSymbols[0]) {
                        $("body").append("<div id='missing_symbols' style='position:absolute;left:100px;top:100px;font-size:18px;'></div>");
                    }
                    $missingSymbols.html($missingSymbols.html() + symbol + "</br>");
                    self.downloadData();
                }
            }, 10000);
            //}
        }
    }

}