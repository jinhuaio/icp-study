import { demo } from "../../declarations/demo";

// document.querySelector("form").addEventListener("submit", async (e) => {
//   e.preventDefault();
//   const button = e.target.querySelector("button");

//   const logger_message = document.getElementById("logger_message").value.toString();

//   button.setAttribute("disabled", true);

//   // Interact with foo actor, calling the greet method
//   const greeting = await demo.append([logger_message]);

//   button.removeAttribute("disabled");

//   document.getElementById("greeting").innerText = greeting;

//   return false;
// });

async function add() {
  let add_button = document.getElementById("add");
  add_button.disabled = true;
  let textarea = document.getElementById("logger_message");
  let text = textarea.value;
  let count = document.getElementById("logger_count");
  let c = count.value;
  try { 
    const msgs = new Array(c);
    for(var index = 0;index < c;index++){
      msgs[index] = text;
    };
    await demo.append(msgs);
    textarea.value = "";
    // alert("新增成功\n" + msgs + c);
    load_logger_stats();
    load_logger_message();
  } catch (error) { 
    alert("新增失败\n" + error);
  }
  add_button.disabled = false;
}

async function search() {
  let search_button = document.getElementById("search");
  search_button.disabled = true;
  await load_logger_stats();
  await load_logger_message();
  search_button.disabled = false;
}

function tableDisplay(sectionId,messages) {
  // 获取table位置标签
  let table_section = document.getElementById(sectionId);
  table_section.replaceChildren([]);
  // 创建表节点 和tbody节点
  var tbl     = document.createElement("table");
  var tblBody = document.createElement("tbody");
  for (var j = 0; j < messages.length; j++) {
      // 添加行tr
      var row = document.createElement("tr");
      let msgItem = messages[j];

      var cell2 = document.createElement("td");
        cell2.style.border=0;
        cell2.style.cellspacing="0";
        cell2.style.cellpadding="0";
        var cellText2 = document.createTextNode(" # "+j + " ");
        cell2.appendChild(cellText2);
        row.appendChild(cell2);
        
        var cell1 = document.createElement("td");
        cell1.style.border=0;
        cell1.style.cellspacing="0";
        cell1.style.cellpadding="0";
        var cellText1 = document.createTextNode("-> "+msgItem);
        cell1.appendChild(cellText1);
        row.appendChild(cell1);
      // 增加到tbody
      tblBody.appendChild(row);
  }
  // 把tbody放入table中
  tbl.appendChild(tblBody);
  // table put to body
  table_section.appendChild(tbl);
  tbl.setAttribute("border", "0");
}

async function load_logger_message() {
  var view_msgs = null;
  let logger_list = document.getElementById("logger_list");
  logger_list.innerText = "  Loading ... ";
  let from = document.getElementById("logger_from").value;
  let to = document.getElementById("logger_to").value;
  try{
    view_msgs = await demo.view(Number(from),Number(to));
  } catch (e) {
    console.warn("load_logger_message: " + e);
  }
  if (view_msgs == null) {
    logger_list.innerText = "  found 0 messages ";
    return 0;
  }
  tableDisplay("logger_list",view_msgs.messages);
}

async function load_logger_stats() {
  var stats = null;
  let logger_stats = document.getElementById("logger_stats");
  logger_stats.innerText = "  Loading ... ";
  try{
    stats = await demo.stats();
  } catch (e) {
    console.warn("load logger_stats: " + e);
  }
  if (stats == null) {
    logger_stats.innerText = "  logger_stats error ";
    return 0;
  } else {
    logger_stats.innerText = "canister count: " + stats.canister_size + " log counts: " + stats.log_size;
  }
}

function load() {
  let add_button = document.getElementById("add");
  add_button.onclick = add;

  let search_button = document.getElementById("search");
  search_button.onclick = search;
  
  load_logger_stats();
  load_logger_message();
}

window.onload = load
