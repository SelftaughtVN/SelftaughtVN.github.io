class rfooter extends HTMLElement {
	constructor() {
        super();
    }
    connectedCallback() {
      this.innerHTML= `<style>
        footer {
            background: #01faff;
            background: radial-gradient(at center, #01faff, #00b2e9);
            padding-top: 5px;
            padding-bottom: 5px;
            margin-top: 40px;
            text-align: left;
        }
        .footnote {
            font-family: Arvo, serif;
            font-size: 0.875em;
            font-weight: 400;
            color: white;
            margin-bottom: 0;
            padding-left: 20px;
        }
        a.email {
            color: white;
            text-decoration: underline white solid auto;
        }
        </style>
        <footer class="py-1 px-0">
            <div class="container">
                <p class="footnote">Asking a question? Email <a class='email' href="mailto:rylex.phan@gmail.com">rylex.phan@gmail.com</a></p>
                <p></p>
                <p class="footnote">We wish you a supercalifragilisticexpialidocious day!</p>
            </div>
        </footer>`
    }
}
customElements.define("r-footer", rfooter);