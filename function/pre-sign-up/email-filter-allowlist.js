exports.handler = (event, context, callback) => {
  // allowed domains
  const ald = process.env.DOMAINALLOWLIST.split(',').map(d => d.trim());

  const { email } = event.request.userAttributes;
  const domain = email.substring(email.indexOf('@') + 1);

  // DEBUG
  console.log("ald: ", ald);
  console.log("domain: ", domain);

  if (!ald.includes(domain)) {
    callback(new Error(`Invalid email domain: ${domain}`), event);
  } else {
    callback(null, event);
  }
};
