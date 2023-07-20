class rfooter extends HTMLElement {
	constructor() {
        super();
    }
    connectedCallback() {
      this.innerHTML= `<style>
        footer {
            background: #01faff;
            background: radial-gradient(at center, #01faff, #00b2e9);
            text-align: left;
            padding: 80px 0 80px 0;
        }
        .footnote {
            font-family: Arvo, serif;
            font-size: 0.875em;
            font-weight: 400;
            color: white;
        }
        a.email {
            color: white;
            text-decoration: underline white solid auto;
        }
        </style>
        <footer>
            <div class="container">
                <p class="footnote">Asking a question? Email <a class='email' href="mailto:rylex.phan@gmail.com">rylex.phan@gmail.com</a></p>
                <p class="footnote">We wish you a supercalifragilisticexpialidocious day!</p>
            </div>
        </footer>`
    }
}
customElements.define("r-footer", rfooter);
