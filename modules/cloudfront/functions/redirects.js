function handler(event) {
    var request = event.request;
  
    var splitHost = request.headers.host.value.split('.');

    if  ( 
        (splitHost.length > 3) &&
        (splitHost[splitHost.length - 1] == 'us') && 
        (splitHost[splitHost.length - 4] == 'devoreandjohnson' ||
         splitHost[splitHost.length - 4] == 'fwcaz' ||
         splitHost[splitHost.length - 4] == 'murraysupply' )) 
    {
        splitHost[splitHost.length - 4] = 'app';

        var adjustedHost = splitHost.join('.');
  
        var response = {
          statusCode: 301,
          statusDescription: 'Moved Permanently',
          headers: {
            location: {
              value: `https://${adjustedHost}${request.uri}`,
            },
          },
        };
      
        return response;
    }
    return request;
}