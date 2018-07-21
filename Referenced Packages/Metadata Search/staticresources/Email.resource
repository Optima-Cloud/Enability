@page {
    size: landscape;
    margin-left: 0.8cm;
    margin-right: 0.8cm;
    margin-top: 0.8cm;
    margin-bottom: 0.8cm;
    @bottom-left {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 8pt;
        content: "Metadata Search Results";
    }
    @bottom-center {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 8pt;
    }
    @bottom-right {
        font-family: Verdana, Arial, Helvetica, sans-serif;
        font-size: 8pt;
        content: "Page " counter(page) " of " counter(pages);
    }
}
@media print
{
  table { page-break-after:auto }
  tr    { page-break-inside:avoid; page-break-after:auto }
  td    { page-break-inside:avoid; page-break-after:auto }
  thead { display:table-header-group }
  tfoot { display:table-footer-group }
}
table {
    page-break-inside: auto;
    border-collapse: collapse;
    width:100%;
    font-size: 11pt;
}
tr {
    page-break-inside: avoid;
    page-break-after: auto;
    height: auto;
}
thead {
    display: table-header-group
}
tfoot {
    display: table-footer-group
}
div td {
    border: 0.4px solid black;
    width: auto;
    height: auto;
    overflow: auto;
    padding: 5px;
    font-size: 0.8em;
}
div td.shrink {
    width: 10%;
}
/*
div.bPageBlock .list {
    width : 70% ;
}
*/
div td.expand {
    height: 99%
}
div th {
    border: 0.4px solid black;
    width: 10%;
    padding: 5px;
    font-size: 0.9em;
}
div.pbHeader {
    font-size: 1.2em;
    border-left: 0.4px solid black;
    width: 100%;
    border-right: 0.4px solid black;
    width: 100%;
    border-top: 0.4px solid black;
    width: 100%;
    border-bottom: 0.4px solid black;
    width: 100%;
}
div img {
    padding-top: 2px;
}
div.MetadataTitle {
  margin-left: 80px ; 
   margin-top : -40px !important  ;
}
.MatchesFound {
  font-size :0.9em; 
  padding-left : 70px;
  margin-Top: -25px;
}
.MetadataLogo {
     margin-Top: -25px;
}
body {
    font-family: Verdana, Geneva, sans-serif;
}
span.MyPbHeader {
    margin-left:5px;
    font-size: 0.9em;
}
div.NOMatchDiv {
    margin-Top: 10px;
    font-family: Verdana, Geneva, sans-serif;
/**    border: 0.4px solid black; **/
    width: 100%;
    font-size: 0.9em;
}
div.pbBody {
    margin-Top: 10px;
    height: auto;
    overflow: inherit;
}
div small {
    /*font-family: Lucida Console, Monaco, monospace*/
    font-family: Verdana, Geneva, sans-serif;
    font-size: 0.6em;
}
div.bPageBlock {
    margin-bottom: 30px;
}
.bPageBlock .list {
    width: 100%;
}
a {
    color:black;
}
.Outerdivclass {
    width: 99%;
}