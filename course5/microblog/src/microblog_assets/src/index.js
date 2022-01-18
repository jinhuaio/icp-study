import { microblog } from "../../declarations/microblog";
export const canisterId = process.env.MICROBLOG_CANISTER_ID;

// document.querySelector("form").addEventListener("submit", async (e) => {
//   e.preventDefault();
//   const button = e.target.querySelector("button");

//   const name = document.getElementById("name").value.toString();

//   button.setAttribute("disabled", true);

//   // Interact with foo actor, calling the greet method
//   const greeting = await microblog.greet(name);

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

async function post() {
  let post_button = document.getElementById("post");
  post_button.disabled = true;
  let textarea = document.getElementById("message");
  let text = textarea.value;
  await microblog.post(text);
  post_button.disabled = false;
  textarea.value = "";
}

var num_posts = 0;
async function load_posts() {
  let posts = await microblog.posts(0);
  if (num_posts == posts.length) return; 
  num_posts = posts.length;
  tableDisplay("posts",posts);
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

        // 添加列td: msg
        var cell = document.createElement("td");
        cell.style.border=0;
        cell.style.cellspacing="0";
        cell.style.cellpadding="0";
        var cellText = document.createTextNode(" "+j+" "+msgItem.msg);
        cell.appendChild(cellText);
        row.appendChild(cell);

        var cell1 = document.createElement("td");
        cell1.style.border=0;
        cell1.style.cellspacing="0";
        cell1.style.cellpadding="0";
        var cellText1 = document.createTextNode("作者："+msgItem.author);
        cell1.appendChild(cellText1);
        row.appendChild(cell1);

        var cell2 = document.createElement("td");
        cell2.style.border=0;
        cell2.style.cellspacing="0";
        cell2.style.cellpadding="0";
        var cellText2 = document.createTextNode("时间："+getdate(msgItem.time) + " ");
        cell2.appendChild(cellText2);
        row.appendChild(cell2);
      // 增加到tbody
      tblBody.appendChild(row);
  }
  // 把tbody放入table中
  tbl.appendChild(tblBody);
  // table put to body
  table_section.appendChild(tbl);
  tbl.setAttribute("border", "0");
}

var author_name = "";
async function load_author_name() {
  let author_name_section = document.getElementById("author_name");
  let name = await microblog.get_name();
  if (author_name == name) return;
  author_name = (name == null ? "?" : name);
  author_name_section.replaceChildren([]);
  let namep = document.createElement("a");
  namep.innerText = author_name;
  author_name_section.appendChild(namep);
}

function load_canisterid() {
  let canid = document.getElementById("canisterid");
  canid.replaceChildren([]);
  let namep = document.createElement("a");
  namep.innerText = canisterId;
  canid.appendChild(namep);
}


function load() {
  let post_button = document.getElementById("post");
  post_button.onclick = post;
  load_canisterid();
  load_posts();
  load_author_name()
  setInterval(load_posts,3000);
  setInterval(load_author_name,3000);
}

window.onload = load


