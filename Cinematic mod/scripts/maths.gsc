/*
 *      IW4cine
 *      !> Credits to the CoDTVMM Team, I merely made it easier on the eyes
 */

koeff( x, y )
{
    return ( fact( y ) / ( fact( x ) * fact( y - x ) ) );
}

fact( x )
{
    c = 1;
    if( x == 0 ) return 1;
    for( i = 1; i <= x; i++ )
        c = c * i;
    return c;
}

pow( a, b )
{
    x = 1;
    if( b != 0 )
    {
        for( i = 1; i <= b; i++ )
            x = x * a;
    }
    return x;
}

mod( a ) 
{
    if ( a >= 0 ) 
        return a;
    return a * ( -1 );
}

crossProduct( vecA, vecB )
{
    a = ( vecA[1] * vecB[2] ) - ( vecA[2] * vecB[1] );
    b = ( vecA[2] * vecB[0] ) - ( vecA[0] * vecB[2] );
    c = ( vecA[0] * vecB[1] ) - ( vecA[1] * vecB[0] );
    return ( a, b, c );
}

getPointOnSpline( cubic, s )
{
    return ( ( ( cubic.d * s ) + cubic.c ) * s + cubic.b ) * s + cubic.a;
}

calcCubicSpline( n, v )
{
    gamma	= []; 
    delta	= []; 
    D		= []; 

    gamma[0] = ( 0.5, 0.5, 0.5 );
    for( i = 1; i < n; i++ ) 
        gamma[i] = ( 1, 1, 1) / ( ( 4 * ( 1, 1, 1 ) ) - gamma[i-1]);
    gamma[n] = ( 1, 1, 1 ) / ( ( 2 * ( 1, 1, 1 ) ) - gamma[n-1] );

    delta[0] = 3 * ( ( v[1] - v[0] ) ) * gamma[0];
    for( i = 1; i < n; i++ ) 
        delta[i] = ( 3 * ( ( v[i + 1] - v[i-1] ) ) - delta[i-1] ) * gamma[i];
    delta[n] = ( 3 * ( ( v[n] - v[n-1] ) ) - delta[n-1] ) * gamma[n];

    D[n] = delta[n];
    for( i = n-1; i >= 0; i-- ) 
        D[i] = delta[i] - gamma[i] * D[i+1];
    

    C = [];
    for( i = 0; i < n; i++) 
        C[i] = createCubic( v[i], D[i], 3 * ( ( v[i+1] - v[i] ) ) - 2 * D[i] - D[i+1], 2 * ( ( v[i] - v[i+1] ) ) + D[i] + D[i+1] );
    
    return C;
}

createCubic( a, b, c, d )
{
    cubic   = spawnstruct();
    cubic.a = a;
    cubic.b = b;
    cubic.c = c;
    cubic.d = d;
    return cubic;
}