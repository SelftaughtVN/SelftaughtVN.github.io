document.addEventListener("DOMContentLoaded", function () {
  var collapsible = document.querySelector(".navbar-collapse");
  var navlinks = document.querySelectorAll(".nav-link");
  var navbar = document.querySelector(".navbar");
  var brandname = document.querySelector(".brandname");
  var iconborder = document.querySelector(".navbar-toggler");
  var icon = document.querySelector(".navbar-toggler-icon");
  function resetNavLinks() {
    navlinks.forEach((elem) => {
      elem.style.color = "";
      elem.style.setProperty("--underline-color", "255,255,255");
    });
  }
  function handleResize() {
    if (window.innerWidth > 767 && window.scrollY == 0) {
      resetNavLinks();
      collapsible.style.backgroundColor = "transparent";
      collapsible.classList.remove("show");
    }
  }
  function handleCollapse() {
    if (window.innerWidth < 768) {
      navlinks.forEach((elem) => {
        elem.style.color = "black";
        elem.style.setProperty("--underline-color", "0,0,0");
      });
      collapsible.style.backgroundColor = "#efefef";
    }
  }
  function handleScroll() {
    if (window.scrollY > 0) {
      navlinks.forEach((elem) => {
        elem.style.color = "black";
        elem.style.setProperty("--underline-color", "0,0,0");
      });
      navbar.classList.add("scroll");
      brandname.style.color = "black";
      iconborder.style.borderColor = "black";
      icon.style.backgroundImage =
        "url(\"data:image/svg+xml;charset=utf8,%3Csvg viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='rgb(0,0,0)' stroke-width='2' stroke-linecap='round' d='M4 8h24M4 16h24M4 24h24'/%3E%3C/svg%3E\")";
    } else {
      navbar.classList.remove("scroll");
      brandname.style.color = "";
      iconborder.style.borderColor = "";
      icon.style.backgroundImage = "";
      if (!collapsible.classList.contains("show") || window.innerWidth > 767) {
        resetNavLinks();
        collapsible.style.backgroundColor = "transparent";
        collapsible.classList.remove("show");
      }
    }
  }
  window.addEventListener("resize", handleResize);
  collapsible.addEventListener("shown.bs.collapse", handleCollapse);
  collapsible.addEventListener("hidden.bs.collapse", handleCollapse);
  window.addEventListener("scroll", handleScroll);
});
