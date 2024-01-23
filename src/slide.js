class rSlide extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = `
        <style>
        button.carousel-control-prev, button.carousel-control-next {
            width: 2.1rem;
            height: 2.1rem;
            margin: 12px 12px 12px 12px;
        }
        div.carousel-item {
            height: calc(100vh - 67.5px);
        }
        </style>
        <div id="carousel" class="carousel slide">        
            <div class="carousel-inner">`
            + this.innerHTML +
            `</div>
            <button class="carousel-control-prev" type="button" data-bs-target="#carousel" data-bs-slide="prev">
                <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Previous</span>
            </button>
            <button class="carousel-control-next" type="button" data-bs-target="#carousel" data-bs-slide="next">
                <span class="carousel-control-next-icon" aria-hidden="true"></span>
                <span class="visually-hidden">Next</span>
            </button>
        </div>
        `
    }
}
customElements.define("r-slide", rSlide);