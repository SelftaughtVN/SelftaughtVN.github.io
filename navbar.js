document.addEventListener("DOMContentLoaded", () => {
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
class rNavbar extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = `
        <style>
            img.logo {
                width: 50px;
                height: auto;
                margin: 5px 0px 0px 25px;
            }
            h5.brandname {
                font-family: Comfortaa, cursive;
                font-size: 0.9em;
                color: white;
                display: inline-block;
            }
            @media only screen and (max-width: 359px) {
                h5.brandname {
                    display: none;
                }
            }
            li.nav-item {
                all: initial;
            }
            a.nav-link, button.nav-link {
                font-family: Comfortaa, cursive;
                font-size: 0.9em;
                --underline-color: 255, 255, 255;
                color: white;
                text-decoration: underline rgba(var(--underline-color), 0) solid 0.2em;
                text-underline-offset: 10px;
                transition: text-decoration-color 300ms;
            }
            a.nav-link:hover, button.nav-link:hover {
                color: white;
                text-decoration-color: rgba(var(--underline-color), 1);
            }
            nav.navbar {
                height: 67.5px;
            }
            button.navbar-toggler {
                border-color: white;
            }
            nav.navbar.transparent {
                background-color: transparent;
                transition: background-color 0.3s ease-in-out;
            }
            nav.navbar.scroll {
                background-color: #efefef;
                transition: background-color 0.3s ease-in-out;
            }
            span.navbar-toggler-icon {
                background-image: url("data:image/svg+xml;charset=utf8,%3Csvg viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath stroke='rgb(255,255,255)' stroke-width='2' stroke-linecap='round' d='M4 8h24M4 16h24M4 24h24'/%3E%3C/svg%3E");
            }
            div.collapse.navbar-collapse {
                background-color: transparent;
                padding-bottom: 7.5px;
                padding-top: 6.5px;
            }
        </style>
        <nav class="navbar fixed-top navbar-expand-md transparent py-0">
            <div class="container-fluid">
                <a class="navbar-brand" href="https://selftaughtvn.github.io">
                    <img src="https://cdn.jsdelivr.net/gh/SelftaughtVN/SelftaughtVN.github.io@main/Images/Logo.svg" width="50px" height="50px" class="logo" alt="logo" />
                    <h5 class="brandname">SelftaughtVN</h5>
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse container-fluid" id="navbarNav">
                    <ul class="navbar-nav ms-auto">`
                    +this.innerHTML+
                    `</ul>
                </div>
            </div>
        </nav>`
    }
}
customElements.define("r-navbar", rNavbar);
