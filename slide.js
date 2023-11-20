class rSlide extends HTMLElement {
    constructor() {
        super();
    }
    connectedCallback() {
        this.innerHTML = `
        <style>
        .carousel-control-prev, .carousel-control-next {
            width: 2rem;
            height: 2rem;
            margin: 10px 10px 10px 10px;
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