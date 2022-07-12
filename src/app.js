App = {
  web3Provider: null,
  contracts: {},
  account: "0x0",

  init: async function () {
    // Processes required before connecting to the decantralized network. Initializing the homepage

    //hide the Your Balance section
    $("#your-balance").hide();
    console.log("App initialized...");

    return await App.initWeb3();
  },

  initWeb3: async function () {
    // Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.request({ method: "eth_requestAccounts" });
      } catch (error) {
        // User denied account access...
        console.error("User denied account access");
      }
    }

    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider(
        "HTTP://127.0.0.1:7545"
      );
    }
    web3 = new Web3(App.web3Provider);

    //check if there is an account, if not, prompt the user to login and select an account
    web3.eth.getAccounts(function (err, accounts) {
      if (err != null) {
        console.log("An error occurred: " + err);
      } else if (accounts.length == 0) {
        console.log("No accounts found");
      } else {
        App.account = accounts[0];
        //a function to show the Your Balance section
        $("#your-balance").show();
        web3.eth.getBalance(App.account, function (err, balance) {
          if (err != null) {
            console.log("An error occurred: " + err);
          } else {
            $("#your-balance").html(
              "Your Balance: " + balance / 10 ** 18 + " ETH"
            );
          }
        });
        //hide the login button
        $("#login_button").hide();
        console.log("Account: " + App.account);
      }
    });

    return App.initContracts();
  },

  initContracts: async function () {
    $.getJSON("ppSwapExchangeCreator.json", function (data) {
      // Get the necessary contract artifact file and instantiate it with @truffle/contract
      var ppDexArtifact = data;
      App.contracts.ppDEX = TruffleContract(ppDexArtifact);

      // Set the provider for our contract
      App.contracts.ppDEX.setProvider(App.web3Provider);
    });

    return App.bindEvents();
  },

  bindEvents: function () {
    // check for the change in input fields, when populated, give estimate
    $(document).on("input", "#from_amount", App.giveEstimate);
    
    // check for the swap button
    $(document).on("click", "#swap_button", App.swap);

    // check for the add liquidity button

    $
  },

  giveEstimate: function () {
    var swapInstance;

    App.contracts.ppDEX.deployed()
      .then(function (instance) {
        swapInstance = instance;

        return swapInstance.getAdopters.call();
      })
      .catch(function (err) {
        console.log(err.message);
      });
  },
};

$(window).on("load", function () {
  App.init();
});

ethereum.on("accountsChanged", function (accounts) {
  //update the account address
  App.account = accounts[0];
  web3.eth.getBalance(App.account, function (err, balance) {
    if (err != null) {
      console.log("An error occurred: " + err);
    } else {
      $("#your-balance").html("Your Balance: " + balance / 10 ** 18 + " ETH");
    }
  });
});