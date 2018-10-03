class NavBar extends React.Component {
  render() {
    return (
        <nav class="navbar navbar-expand-lg navbar-light bg-light fixed-top">
            <div class="container">
                <a class="navbar-brand" href="#">ASP.Net Core 2.1 MVC</a>
                <div class="collapse navbar-collapse" id="navbarResponsive">
                    <ul class="navbar-nav ml-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="#">Shop</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Cart</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">Checkout</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" href="#">{this.props.data.firstname} {this.props.data.surname}</a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    );
  }
}

class JumboTron extends React.Component {
  render() {
    return (
        <header class="jumbotron my-4">
            <h1 class="display-3">Store2018</h1>
            <p class="lead">Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ipsa, ipsam, eligendi, in quo sunt possimus non incidunt odit vero aliquid similique quaerat nam nobis illo aspernatur vitae fugiat numquam repellat.</p>
        </header>
    );
  }
}

class Footer extends React.Component {
  render() {
    return (
        <footer class="py-5 bg-dark">
            <div class="container">
                <p class="m-0 text-center text-white">CloudAcademy 2018 ♥ DevOps & Microservices</p>
            </div>
        </footer>  
    );
  }
}

class Product extends React.Component {
  render() {
    return (
        <div class="col-lg-3 col-md-6 mb-4">
            <div class="card">
                <img class="card-img-top" src="http://placehold.it/500x325" alt=""/>
                <div class="card-body">
                    <h4 class="card-title">{this.props.name}</h4>
                    <div class="card-text">{this.props.sku}</div>
                    <div class="card-text">{this.props.regularPrice}</div>
                </div>
                <div class="card-footer">
                    <a href="#" class="btn btn-primary">Add to Cart</a>
                </div>
            </div>
        </div>
    );
  }
}

class ProductList extends React.Component {
  render() {
    const productNodes = this.props.data.map(product => (     
      <Product
        key={product.id}
        name={product.name}
        sku={product.sku}
        regularPrice={product.regularPrice}
      />
    ));
    return (
      <div class="row text-center">
        {productNodes}
      </div>
    );
  }
}

class Shop2018 extends React.Component {
  constructor(props) {
    super(props);
    this.state = {products: [], consumer: []};
  }
  componentWillMount() {
    const xhr1 = new XMLHttpRequest();
    xhr1.open('get', this.props.consumer, true);
    xhr1.onload = () => {
      const data = JSON.parse(xhr1.responseText);
      this.setState({ consumer: data });
    };
    xhr1.send();

    const xhr2 = new XMLHttpRequest();
    xhr2.open('get', this.props.products, true);
    xhr2.onload = () => {
      const data = JSON.parse(xhr2.responseText);
      this.setState({ products: data });
    };
    xhr2.send();

  }
  render() {
    return (
        <div>
            <NavBar data={this.state.consumer} />
                <div class="container">        
                    <JumboTron/>     
                    <ProductList data={this.state.products} />
                </div>
            <Footer/>
        </div>
    );
  }
}

ReactDOM.render( 
  <Shop2018
    /* Shop2018 component */
    consumer="https://api-accounts.democloudinc.com/api/Consumers/5"
    products="https://api-products.democloudinc.com/api/Products"
    /*
    consumer="http://localhost:8081/api/consumers/5"
    products="http://localhost:8082/api/products"
    */
  />,
  document.getElementById('content')
);
