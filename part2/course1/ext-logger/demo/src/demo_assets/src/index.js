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

function getdate(time) {
  var t = Number(time / 1000000n);
  var ns =Number(time % 1000000n);
  var now = new Date(t),
        y = now.getFullYear(),
        m = now.getMonth() + 1,
        d = now.getDate();
  return y + "-" + (m < 10 ? "0" + m : m) + "-" + (d < 10 ? "0" + d : d) + " " + now.toTimeString().substr(0, 8) + " " + ns;
}

async function add() {
  let add_button = document.getElementById("add");
  add_button.disabled = true;
  let textarea = document.getElementById("logger_message");
  let text = textarea.value;
  let count = document.getElementById("logger_count");
  let c = count.value;
  try { 
    //为了方便测试，批量添加日志信息
    const msgs = new Array(c);
    for(var index = 0;index < c;index++){
      msgs[index] = "批量添加的第 " + index + " 条日志:" + text;
    };
    await demo.append(msgs);
    textarea.value = "";
    // alert("新增成功\n" + msgs + c);
    await load_logger_stats();
    await load_logger_message();
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

function tableDisplay(sectionId,msgs) {
  // 获取table位置标签
  let table_section = document.getElementById(sectionId);
  table_section.replaceChildren([]);
  let startIndex = Number(msgs.start_index);
  let messages = msgs.messages;
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
        var cellText2 = document.createTextNode(" # "+ (startIndex + j) + " # Time ："+getdate(msgItem.time) + " ");
        cell2.appendChild(cellText2);
        row.appendChild(cell2);
        
        var cell1 = document.createElement("td");
        cell1.style.border=0;
        cell1.style.cellspacing="0";
        cell1.style.cellpadding="0";
        var cellText1 = document.createTextNode(" canister:"+ msgItem.canisterId + " -> "+msgItem.message);
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
  if (logger_list.value === null || logger_list.value === "") {
    logger_list.innerText = "  Loading ... ";
  };
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
  tableDisplay("logger_list",view_msgs);
}

async function load_logger_stats() {
  var stats = null;
  let logger_stats = document.getElementById("logger_stats");
  if (logger_stats.value === null || logger_stats.value === "") {
    logger_stats.innerText = "  Loading ... ";
  };
  
  try{
    stats = await demo.stats();
  } catch (e) {
    console.warn("load logger_stats: " + e);
  }
  if (stats == null) {
    logger_stats.innerText = "  logger_stats error ";
    return 0;
  } else {
    logger_stats.innerText = "每个Canister最大日志数( "+ stats.canister_log_max_size + " ) Canister数量( " + stats.canister_count + " )  日志条数( " + stats.log_size+" )";
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
