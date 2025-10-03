import { APIRequestContext, expect } from '@playwright/test';

export interface ApiResponse {
  status: number;
  data: any;
  headers: Record<string, string>;
}

export class ApiHelper {
  constructor(private request: APIRequestContext) {}

  async get(endpoint: string, options: {
    headers?: Record<string, string>;
    params?: Record<string, string | number>;
  } = {}): Promise<ApiResponse> {
    const url = this.buildUrl(endpoint, options.params);
    const response = await this.request.get(url, {
      headers: options.headers
    });

    return {
      status: response.status(),
      data: await this.parseResponse(response),
      headers: response.headers()
    };
  }

  async post(endpoint: string, options: {
    data?: any;
    headers?: Record<string, string>;
    params?: Record<string, string | number>;
  } = {}): Promise<ApiResponse> {
    const url = this.buildUrl(endpoint, options.params);
    const response = await this.request.post(url, {
      data: options.data,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    });

    return {
      status: response.status(),
      data: await this.parseResponse(response),
      headers: response.headers()
    };
  }

  async put(endpoint: string, options: {
    data?: any;
    headers?: Record<string, string>;
    params?: Record<string, string | number>;
  } = {}): Promise<ApiResponse> {
    const url = this.buildUrl(endpoint, options.params);
    const response = await this.request.put(url, {
      data: options.data,
      headers: {
        'Content-Type': 'application/json',
        ...options.headers
      }
    });

    return {
      status: response.status(),
      data: await this.parseResponse(response),
      headers: response.headers()
    };
  }

  async delete(endpoint: string, options: {
    headers?: Record<string, string>;
    params?: Record<string, string | number>;
  } = {}): Promise<ApiResponse> {
    const url = this.buildUrl(endpoint, options.params);
    const response = await this.request.delete(url, {
      headers: options.headers
    });

    return {
      status: response.status(),
      data: await this.parseResponse(response),
      headers: response.headers()
    };
  }

  async verifyStatusCode(response: ApiResponse, expectedStatus: number): Promise<void> {
    expect(response.status).toBe(expectedStatus);
  }

  async verifyResponseContains(response: ApiResponse, expectedData: any): Promise<void> {
    if (typeof expectedData === 'object') {
      expect(response.data).toMatchObject(expectedData);
    } else {
      expect(response.data).toContain(expectedData);
    }
  }

  async verifyResponseSchema(response: ApiResponse, schema: any): Promise<void> {
    // Basic schema validation - in a real project you might use a library like Joi or Ajv
    this.validateObjectStructure(response.data, schema);
  }

  private buildUrl(endpoint: string, params?: Record<string, string | number>): string {
    let url = endpoint;
    
    if (params) {
      const searchParams = new URLSearchParams();
      Object.entries(params).forEach(([key, value]) => {
        searchParams.append(key, value.toString());
      });
      url += `?${searchParams.toString()}`;
    }
    
    return url;
  }

  private async parseResponse(response: any): Promise<any> {
    const contentType = response.headers()['content-type'] || '';
    
    if (contentType.includes('application/json')) {
      try {
        return await response.json();
      } catch {
        return await response.text();
      }
    } else {
      return await response.text();
    }
  }

  private validateObjectStructure(obj: any, schema: any): void {
    for (const key in schema) {
      if (schema.hasOwnProperty(key)) {
        expect(obj).toHaveProperty(key);
        
        if (typeof schema[key] === 'object' && schema[key] !== null) {
          if (Array.isArray(schema[key])) {
            expect(Array.isArray(obj[key])).toBe(true);
          } else {
            this.validateObjectStructure(obj[key], schema[key]);
          }
        } else {
          expect(typeof obj[key]).toBe(typeof schema[key]);
        }
      }
    }
  }

  // Utility methods for common API testing scenarios
  async verifyApiHealth(healthEndpoint: string = '/health'): Promise<boolean> {
    try {
      const response = await this.get(healthEndpoint);
      return response.status === 200;
    } catch {
      return false;
    }
  }

  async performLoginViaApi(credentials: {
    email: string;
    password: string;
  }): Promise<ApiResponse> {
    return await this.post('/api/login', {
      data: credentials
    });
  }

  async getProductsViaApi(): Promise<ApiResponse> {
    return await this.get('/api/productsList');
  }

  async searchProductsViaApi(searchTerm: string): Promise<ApiResponse> {
    return await this.post('/api/searchProduct', {
      data: { search_product: searchTerm }
    });
  }
}
